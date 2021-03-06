#! /bin/bash

# libreria di appoggio
. ../installLib.sh

QUEUEMETRICS="/usr/local/queuemetrics/tomcat/webapps/queuemetrics"
FILESQL="$QUEUEMETRICS/WEB-INF/README/queuemetrics_sample.sql"
CPROPSQM="$QUEUEMETRICS/WEB-INF/configuration.properties"
FILEAST="$QUEUEMETRICS/WEB-INF/mysql-utils/extensions-examples/extensions_queuemetrics_18.conf"
FILEELA="/etc/asterisk/extensions_queuemetrics.conf"
FILEAPP="/etc/asterisk/extensions_custom.conf"
SETPROPS="uniloader cfgfile put --properties-file $CPROPSQM "

# Gestione AMI
FILEAMIQM="/etc/asterisk/manager_queuemetrics.conf"
FILEAMI="/etc/asterisk/manager_custom.conf"
AMIPASSWD=`< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-15};echo;`
echo "" > $FILEAMIQM
echo "[queuemetrics] ; generated by QM Espresso" >> $FILEAMIQM
echo "secret = $AMIPASSWD" >> $FILEAMIQM
echo "deny = 0.0.0.0/0.0.0.0" >> $FILEAMIQM
echo "permit= 127.0.0.1/255.255.255.0" >> $FILEAMIQM
echo "read = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate" >> $FILEAMIQM
echo "write = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate" >> $FILEAMIQM
echo "writetimeout = 5000" >> $FILEAMIQM

PWD=`pwd`

echo "FreePBX - Installing $0 from $PWD";
echo "File: $FILESQL"

/etc/init.d/uniloader stop
/etc/init.d/queuemetrics stop



echo "" | mysql -uqueuemetrics -pjavadude queuemetrics

if [ $? -ge 1 ]; then

echo "Creating database"

mysql -uroot mysql <<"EOF"
  CREATE DATABASE IF NOT EXISTS queuemetrics;
  GRANT ALL PRIVILEGES ON queuemetrics.* TO 'queuemetrics'@'localhost' IDENTIFIED BY  'javadude';
EOF

mysql -uqueuemetrics -pjavadude queuemetrics < $FILESQL

fi

echo FreePBX config

FOUND="$(grep 'extensions_queuemetrics.conf' $FILEAPP)"
if [ -z "$FOUND" ]; then
    echo "#include extensions_queuemetrics.conf" >> $FILEAPP
fi

FOUND="$(grep 'manager_queuemetrics.conf' $FILEAMI)"
if [ -z "$FOUND" ]; then
    echo "#include manager_queuemetrics.conf" >> $FILEAMI
fi


cp $FILEAST $FILEELA

rext $FILEELA 11 7 'ChanSpy(${QM_AGENT_LOGEXT})'
rext $FILEELA 14 6 'ChanSpy(${QM_AGENT_LOGEXT})'

asterisk -rx "core reload"


echo Setting QM configuration properties

${SETPROPS} --property "callfile.dir" --value "tcp:queuemetrics:${AMIPASSWD}@127.0.0.1" 
${SETPROPS} --property "default.queue_log_file" --value "sql:P001" 
${SETPROPS} --property "realtime.max_bytes_agent" --value "65000"
${SETPROPS} --property "realtime.agent_button_1.enabled" --value "false"
${SETPROPS} --property "realtime.agent_button_2.enabled" --value "false"
${SETPROPS} --property "realtime.agent_button_3.enabled" --value "false"

${SETPROPS} --property "realtime.agent_button_4.enabled" --value "false"

${SETPROPS} --property "default.monitored_calls" --value "/var/spool/asterisk/monitor/"

${SETPROPS} --property "realtime.members_only" --value "false"

${SETPROPS} --property "realtime.refresh_time" --value "10"

${SETPROPS} --property "callfile.agentlogin.enabled" --value "false"

${SETPROPS} --property "callfile.agentlogoff.enabled" --value "false"

${SETPROPS} --property "callfile.transfercall.enabled" --value "true"

${SETPROPS} --property "default.rewriteLocalChannels" --value "true"

${SETPROPS} --property "default.hotdesking" --value "86400"

${SETPROPS} --property "default.alwaysLogonUnpaused" --value "true"

${SETPROPS} --property "cluster.servers" --value "freepbx"

${SETPROPS} --property "default.crmapp" --value "http://www.queuemetrics.com/sample_screen_pop.jsp?agent=[A]\&unique=[U]"

${SETPROPS} --property "cluster.freepbx.manager" --value "tcp:queuemetrics:${AMIPASSWD}@127.0.0.1"

${SETPROPS} --property "cluster.freepbx.queuelog" --value "sql:P001"

${SETPROPS} --property "cluster.freepbx.monitored_calls" --value "/var/spool/asterisk/monitor/"

${SETPROPS} --property "cluster.freepbx.callfile.dir" --value "tcp:queuemetrics:${AMIPASSWD}@127.0.0.1"

${SETPROPS} --property "realtime.useActivePolling" --value "true"

${SETPROPS} --property "realtime.ajaxPollingDelay" --value "5"

${SETPROPS} --property "realtime.useRowCache" --value "true"

${SETPROPS} --property "realtime.agent_autoopenurl" --value "true"

${SETPROPS} --property "default.exitOnAgentDumpSysCompat" --value "false"



sleep 5
killall -9  /usr/local/queuemetrics/java/bin/java

/etc/init.d/uniloader start
/etc/init.d/queuemetrics start

echo Creating espresso user...
sleep 5

uniloader user --login "root" --pwd "" add-user -u espresso -c ADMIN --fullname "Espresso Installation" --locked "NO" --new-password "espresso"

echo Reading extensions and queues from FREEPBX

uniloader pbxinfo --mode "printjson" --uri "http://127.0.0.1:8080/queuemetrics" --login "espresso" --pass "espresso" freepbx
uniloader pbxinfo --mode "syncqm" --uri "http://127.0.0.1:8080/queuemetrics" --login "espresso" --pass "espresso" freepbx

mainTechnology=$(mysql -uroot asterisk -se "
  	SELECT
  		*
	FROM
	  (
	    select
	      tech,
	      count(*) as "nofdevices"
	    from
	      devices
	    group by
	      tech
	  ) as t
	  JOIN (
	    SELECT
	      max(nofdevices) as maxDevices
	    from
	      (
	        select
	          tech,
	          count(*) as "nofdevices"
	        from
	          devices
	        group by
	          tech
	      ) as b
	  ) as c
	where
	  maxDevices = nofdevices
	LIMIT 1
" |  awk '{print $1;}')


if [ "$mainTechnology" == "sip" ]; then
    echo "Setting SIP as main main technology."
    ${SETPROPS} --property "platform.directami.extension" --value "SIP/\${num}"
else
    echo "Setting PJSIP as main technology."
    ${SETPROPS} --property "platform.directami.extension" --value "PJSIP/\${num}"
fi

# Creare file configurazione per qmSync
echo "Creating qmSync configuration file"

cat > /usr/local/queuemetrics/qmSync.conf << EOF
# QueueMetrics-FreePBX Synchronization Settings 
URI=http://127.0.0.1:8080/queuemetrics 
USER=espresso 
PASSWORD=espresso 
EOF

echo "Adding /usr/local/queuemetrics to PATH"
# Creare il comando qmSync, 
cat > /usr/local/queuemetrics/qmSync << EOF
#!/bin/bash
. /usr/local/queuemetrics/qmSync.conf
uniloader pbxinfo --mode "syncqm" --uri \${URI} --login \${USER} --pass \${PASSWORD} freepbx
EOF

chmod 700 /usr/local/queuemetrics/qmSync
ln -s /usr/local/queuemetrics/qmSync /usr/local/bin/qmSync

# Tolgo la modalità DELETE dal Synchronizer.
${SETPROPS} --property "default.synchronizer_mode" --value "CR_UPD_USR"
allOK


