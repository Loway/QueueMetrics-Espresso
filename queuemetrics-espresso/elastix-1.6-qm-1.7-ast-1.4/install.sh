#! /bin/bash

# ---
# Elastix 1.6
#
# Aggiunta passsword AMI su /etc/elastix.conf
# ---

# libreria di appoggio
. ../installLib.sh

QUEUEMETRICS="/usr/local/queuemetrics/tomcat/webapps/queuemetrics"
FILESQL="$QUEUEMETRICS/WEB-INF/README/queuemetrics_sample.sql"
CPROPSQM="$QUEUEMETRICS/WEB-INF/configuration.properties"
FILEAST="$QUEUEMETRICS/WEB-INF/mysql-utils/extensions-examples/extensions_queuemetrics_18.conf"
FILEELA="/etc/asterisk/extensions_queuemetrics.conf"
FILEAPP="/etc/asterisk/extensions.conf"
ROOTPASSWD="eLaStIx.2oo7"
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

echo Elastix config

FOUND="$(grep 'extensions_queuemetrics.conf' $FILEAPP)"
if [ -z "$FOUND" ]; then
    echo "#include extensions_queuemetrics.conf" >> $FILEAPP
fi

cp $FILEAST $FILEELA

rext $FILEELA 11 7 'ChanSpy(${QM_AGENT_LOGEXT})'
rext $FILEELA 14 6 'ChanSpy(${QM_AGENT_LOGEXT})'

asterisk -rx reload

echo QM config


rv $CPROPSQM callfile.dir tcp:admin:elastix456@127.0.0.1

rv $CPROPSQM default.queue_log_file sql:P001
rv $CPROPSQM realtime.max_bytes_agent 10000
rv $CPROPSQM realtime.agent_button_1.enabled false
rv $CPROPSQM realtime.agent_button_2.enabled false
rv $CPROPSQM realtime.agent_button_3.enabled false
rv $CPROPSQM realtime.agent_button_4.enabled false

rv $CPROPSQM default.monitored_calls /var/spool/asterisk/monitor/

rv $CPROPSQM realtime.members_only false
rv $CPROPSQM realtime.refresh_time 10
rv $CPROPSQM callfile.agentlogin.enabled false
rv $CPROPSQM callfile.agentlogoff.enabled false

rv $CPROPSQM default.rewriteLocalChannels true

rv $CPROPSQM default.hotdesking 86400
rv $CPROPSQM default.alwaysLogonUnpaused true

rv $CPROPSQM cluster.servers elastix

add $CPROPSQM cluster.elastix.manager tcp:admin:elastix456@127.0.0.1
add $CPROPSQM cluster.elastix.queuelog sql:P001
add $CPROPSQM cluster.elastix.monitored_calls /var/spool/asterisk/monitor/
add $CPROPSQM cluster.elastix.callfile.dir tcp:admin:elastix456@127.0.0.1


sleep 5
killall -9  /usr/local/queuemetrics/java/bin/java

/etc/init.d/qloaderd start
/etc/init.d/queuemetrics start

allOK


