#! /bin/bash

# ---
#
#
# ---

# libreria di appoggio
. ../installLib.sh

QUEUEMETRICS="/usr/local/queuemetrics/tomcat/webapps/queuemetrics"
FILESQL="$QUEUEMETRICS/WEB-INF/README/queuemetrics_sample.sql"
CPROPSQM="$QUEUEMETRICS/WEB-INF/configuration.properties"
FILEAST="$QUEUEMETRICS/WEB-INF/mysql-utils/extensions-examples/extensions_queuemetrics_18.conf"
FILEELA="/etc/asterisk/extensions_queuemetrics.conf"
FILEAPP="/etc/asterisk/extensions_custom.conf"
FILEAMI="/etc/asterisk/manager_additional.conf"
ROOTPASSWD=passw0rd
AMIPASSWD=qmamipw0rd
PWD=`pwd`

echo "Elastix - Installing $0 from $PWD";
echo "File: $FILESQL"

/etc/init.d/qloaderd stop
/etc/init.d/queuemetrics stop



echo "" | mysql -uqueuemetrics -pjavadude queuemetrics

if [ $? -ge 1 ]; then

echo "Creating database"

mysql -uroot -p$ROOTPASSWD mysql <<"EOF"
  CREATE DATABASE IF NOT EXISTS queuemetrics;
  GRANT ALL PRIVILEGES ON queuemetrics.* TO 'queuemetrics'@'localhost' IDENTIFIED BY  'javadude';
EOF

mysql -uqueuemetrics -pjavadude queuemetrics < $FILESQL

fi

echo TrixBox config

FOUND="$(grep 'extensions_queuemetrics.conf' $FILEAPP)"
if [ -z "$FOUND" ]; then
    echo "#include extensions_queuemetrics.conf" >> $FILEAPP
fi

cp $FILEAST $FILEELA

rext $FILEELA 11 7 'ChanSpy(${QM_AGENT_LOGEXT})'
rext $FILEELA 14 6 'ChanSpy(${QM_AGENT_LOGEXT})'
rext $FILEELA 22 3 'PauseQueueMember(,Local/${AGENTCODE}@from-internal/n)'
rext $FILEELA 23 3 'UnpauseQueueMember(,Local/${AGENTCODE}@from-internal/n)'
rext $FILEELA 25 3 'AddQueueMember(${QUEUENAME},Local/${AGENTCODE}@from-internal/n)'
rext $FILEELA 27 3 'RemoveQueueMember(${QUEUENAME},Local/${AGENTCODE}@from-internal/n)'

asterisk -rx "module reload"


echo QM config

rv $CPROPSQM default.queue_log_file sql:P001

rv $CPROPSQM realtime.max_bytes_agent 10000
rv $CPROPSQM realtime.agent_button_1.enabled false
rv $CPROPSQM realtime.agent_button_2.enabled false
rv $CPROPSQM realtime.agent_button_3.enabled false
rv $CPROPSQM realtime.agent_button_4.enabled false

rv $CPROPSQM default.monitored_calls /var/spool/asterisk/monitor/

rv $CPROPSQM layout.logo http://www.loway.ch/images/logo_trixbox_200x72.png

rv $CPROPSQM realtime.members_only false
rv $CPROPSQM realtime.refresh_time 10
rv $CPROPSQM callfile.agentlogin.enabled false
rv $CPROPSQM callfile.agentlogoff.enabled false

rv $CPROPSQM default.rewriteLocalChannels true

rv $CPROPSQM default.hotdesking 86400
rv $CPROPSQM default.alwaysLogonUnpaused true

rv $CPROPSQM callfile.dir tcp:qmadmin:${AMIPASSWD}@127.0.0.1

rv $CPROPSQM cluster.servers trixbox
add $CPROPSQM cluster.trixbox.manager=tcp:admin:amp111@127.0.0.1
add $CPROPSQM cluster.trixbox.queuelog=sql:P001
add $CPROPSQM cluster.trixbox.monitored_calls=/var/spool/asterisk/monitor/


addrawline $FILEAMI [qmadmin]
add $FILEAMI secret ${AMIPASSWD}
add $FILEAMI deny 0.0.0.0/0.0.0.0
add $FILEAMI permit 127.0.0.1/255.255.255.0
add $FILEAMI read system,call,log,verbose,command,agent,user,originate
add $FILEAMI write system,call,log,verbose,command,agent,user,originate


#rv $FILECFG default.queue_log_file sql:P001
#rv $FILECFG realtime.max_bytes_agent 10000
#rv $FILECFG default.monitored_calls /var/spool/asterisk/monitor/
#rv $FILECFG layout.logo http://www.loway.ch/images/logo_elastix_200x72.png
#rv $FILECFG callfile.dir tcp:admin:elastix456@127.0.0.1

sleep 5
killall -9  /usr/local/queuemetrics/java/bin/java

/usr/sbin/asterisk -rx "manager reload"
/etc/init.d/qloaderd start
/etc/init.d/queuemetrics start

allOK


