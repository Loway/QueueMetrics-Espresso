#! /bin/bash

# ---
# Ombutel 1.0
#
# ---

# libreria di appoggio

echo "Ombutel !";

. ../installLib.sh

QUEUEMETRICS="/usr/local/queuemetrics/tomcat/webapps/queuemetrics"
FILESQL="$QUEUEMETRICS/WEB-INF/README/queuemetrics_sample.sql"
CPROPSQM="$QUEUEMETRICS/WEB-INF/configuration.properties"
FILEAST="$QUEUEMETRICS/WEB-INF/mysql-utils/extensions-examples/extensions_queuemetrics_18.conf"
FILEOMB="/etc/asterisk/ombutel/extensions__60-queuemetrics.conf"
ROOTPASSWD=
AMIPASSWD=`grep secret /etc/asterisk/ombutel/manager__50-ombutel-user.conf | cut -d' ' -f 3`
PWD=`pwd`

echo "Ombutel - Installing $0 from $PWD";
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

echo Ombutel config


cp $FILEAST $FILEOMB

rext $FILEELA 11 7 'ChanSpy(${QM_AGENT_LOGEXT})'
rext $FILEELA 14 6 'ChanSpy(${QM_AGENT_LOGEXT})'

asterisk -rx "core reload"


echo QM config

rv $CPROPSQM callfile.dir tcp:astmanager:${AMIPASSWD}@127.0.0.1

rv $CPROPSQM default.queue_log_file sql:P001
rv $CPROPSQM realtime.max_bytes_agent 65000
rv $CPROPSQM realtime.agent_button_1.enabled false
rv $CPROPSQM realtime.agent_button_2.enabled false
rv $CPROPSQM realtime.agent_button_3.enabled false
rv $CPROPSQM realtime.agent_button_4.enabled false

rv $CPROPSQM default.monitored_calls /var/spool/asterisk/monitor/
rv $CPROPSQM layout.logo http://www.loway.ch/images/logo_ombutel_200x72.png

rv $CPROPSQM realtime.members_only false
rv $CPROPSQM realtime.refresh_time 10
rv $CPROPSQM callfile.agentlogin.enabled false
rv $CPROPSQM callfile.agentlogoff.enabled false
rv $CPROPSQM callfile.transfercall.enabled false

rv $CPROPSQM default.rewriteLocalChannels false

rv $CPROPSQM default.hotdesking 86400
rv $CPROPSQM default.alwaysLogonUnpaused true
#rv $CPROPSQM default.autoconf.realtimeuri -

rv $CPROPSQM cluster.servers ombutel

rv $CPROPSQM default.crmapp "http://www.queuemetrics.com/sample_screen_pop.jsp?agent=[A]\&unique=[U]"

add $CPROPSQM cluster.ombutel.manager tcp:astmanager:${AMIPASSWD}@127.0.0.1
add $CPROPSQM cluster.ombutel.queuelog sql:P001
add $CPROPSQM cluster.ombutel.monitored_calls /var/spool/asterisk/monitor/
add $CPROPSQM cluster.ombutel.callfile.dir tcp:astmanager:${AMIPASSWD}@127.0.0.1

add $CPROPSQM realtime.useActivePolling true
add $CPROPSQM realtime.ajaxPollingDelay 5
add $CPROPSQM realtime.useRowCache true
add $CPROPSQM realtime.agent_autoopenurl true

sleep 5
yum install -y psmisc
killall -9  /usr/local/queuemetrics/java/bin/java

/etc/init.d/qloaderd start
/etc/init.d/queuemetrics start

allOK


