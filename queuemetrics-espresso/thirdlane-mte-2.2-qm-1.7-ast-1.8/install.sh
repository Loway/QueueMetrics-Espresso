#! /bin/bash

# ---
# Thirdlane MTE 2.2
#
# ---

# libreria di appoggio
. ../installLib.sh

QUEUEMETRICS="/usr/local/queuemetrics/tomcat/webapps/queuemetrics"
FILESQL="$QUEUEMETRICS/WEB-INF/README/queuemetrics_sample.sql"
CPROPSQM="$QUEUEMETRICS/WEB-INF/configuration.properties"
FILEAST="$QUEUEMETRICS/WEB-INF/mysql-utils/extensions-examples/extensions_queuemetrics_18.conf"
FILEELA="/etc/asterisk/extensions_queuemetrics.conf"
FILEAPP="/etc/asterisk/user_scripts.include"
ROOTPASSWD=passw0rd
AMIPASSWD=insecure
PWD=`pwd`

echo "Thirdlane - Installing $0 from $PWD";
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

echo Thirdlane config

FOUND="$(grep 'extensions_queuemetrics.conf' $FILEAPP)"
if [ -z "$FOUND" ]; then
    echo "#include extensions_queuemetrics.conf" >> $FILEAPP
fi

cp $FILEAST $FILEELA

rext $FILEELA 11 7 'ChanSpy(${QM_AGENT_LOGEXT})'
rext $FILEELA 14 6 'ChanSpy(${QM_AGENT_LOGEXT})'
rextN $FILEELA 31 ChannelRedirect 'ChannelRedirect(${CALLID},from-inside,${REDIR_EXT},1)'

asterisk -rx reload


echo QM config

rv $CPROPSQM callfile.dir tcp:manager:${AMIPASSWD}@127.0.0.1
rv $CPROPSQM cluster.elastix.manager tcp:manager:${AMIPASSWD}@127.0.0.1

rv $CPROPSQM default.queue_log_file sql:P001
rv $CPROPSQM realtime.max_bytes_agent 10000
rv $CPROPSQM realtime.agent_button_1.enabled false
rv $CPROPSQM realtime.agent_button_2.enabled false
rv $CPROPSQM realtime.agent_button_3.enabled false
rv $CPROPSQM realtime.agent_button_4.enabled false

rv $CPROPSQM default.monitored_calls /var/spool/asterisk/monitor/
rv $CPROPSQM layout.logo http://www.loway.ch/images/logo_thirdlane_200x72.png

rv $CPROPSQM realtime.members_only false
rv $CPROPSQM realtime.refresh_time 10
rv $CPROPSQM callfile.agentlogin.enabled false
rv $CPROPSQM callfile.agentlogoff.enabled false
rv $CPROPSQM callfile.transfercall.enabled false

rv $CPROPSQM default.rewriteLocalChannels false

rv $CPROPSQM default.hotdesking 86400
rv $CPROPSQM default.alwaysLogonUnpaused true
rv $CPROPSQM default.stripChannelNames false
#rv $CPROPSQM default.autoconf.realtimeuri -

rv $CPROPSQM cluster.servers elastix

#
# chiamte dirette
rv $CPROPSQM callfile.customdial.channel SIP/\$EM
rv $CPROPSQM callfile.monitoring.channel SIP/\$EM-\$AE
rv $CPROPSQM callfile.outmonitoring.channel SIP/\$EM-\$AE


add $CPROPSQM cluster.elastix.manager tcp:maanager:${AMIPASSWD}@127.0.0.1
add $CPROPSQM cluster.elastix.queuelog sql:P001
add $CPROPSQM cluster.elastix.monitored_calls /var/spool/asterisk/monitor/
add $CPROPSQM cluster.elastix.callfile.dir tcp:manager:${AMIPASSWD}@127.0.0.1



sleep 5
killall -9  /usr/local/queuemetrics/java/bin/java

/etc/init.d/qloaderd start
/etc/init.d/queuemetrics start

allOK


