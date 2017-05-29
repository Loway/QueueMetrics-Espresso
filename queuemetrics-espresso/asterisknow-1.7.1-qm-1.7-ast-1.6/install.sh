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
PWD=`pwd`

echo "AsteriskNow - Installing $0 from $PWD";
echo "File: $FILESQL"

/etc/init.d/qloaderd stop
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

echo AsteriskNow config

if [ ! -f $FILEAPP ]; then
    touch $FILEAPP
fi

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

/etc/init.d/asterisk restart

echo QM config

rv $CPROPSQM default.queue_log_file sql:P001
rv $CPROPSQM realtime.max_bytes_agent 10000
rv $CPROPSQM realtime.agent_button_1.enabled false
rv $CPROPSQM realtime.agent_button_2.enabled false
rv $CPROPSQM realtime.agent_button_4.enabled false
rv $CPROPSQM default.monitored_calls /var/spool/asterisk/monitor/
rv $CPROPSQM layout.logo http://www.loway.ch/images/logo_asterisknow_200x72.png
rv $CPROPSQM realtime.members_only false
rv $CPROPSQM realtime.refresh_time 10
rv $CPROPSQM callfile.dir tcp:admin:amp111@127.0.0.1
rv $CPROPSQM callfile.agentlogin.enabled false
rv $CPROPSQM callfile.agentlogoff.enabled false
rv $CPROPSQM default.rewriteLocalChannels true
rv $CPROPSQM default.hotdesking 86400

rv $CPROPSQM cluster.servers astnow

add $CPROPSQM cluster.astnow.manager tcp:admin:amp111@127.0.0.1
add $CPROPSQM cluster.astnow.queuelog sql:P001
add $CPROPSQM cluster.astnow.monitored_calls /var/spool/asterisk/monitor/

rv $CPROPSQM cluster.aleph.manager tcp:admin:amp111@127.0.0.1
rv $CPROPSQM cluster.aleph.monitored_calls /var/spool/asterisk/monitor/
rv $CPROPSQM cluster.aleph.callfile.dir tcp:admin:amp111@127.0.0.1
rv $CPROPSQM cluster.trix.monitored_calls /var/spool/asterisk/monitor/
rv $CPROPSQM cluster.trix.callfile.dir tcp:admin:amp111@127.0.0.1


sleep 5
killall -9  /usr/local/queuemetrics/java/bin/java

/etc/init.d/qloaderd start
/etc/init.d/queuemetrics start

allOK


