#!/bin/bash

if [ "$( mysqlshow queuemetrics > /dev/null 2>&1 ; echo "${?}" )" = "0" ]
then
	echo "QueueMetrics database already there; aborting..."
	exit 0
fi

/etc/init.d/uniloader stop

mysql -e "CREATE DATABASE queuemetrics CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql -e "CREATE USER 'queuemetrics'@'localhost' identified by 'javadude';"
mysql -e "grant all on queuemetrics.* to 'queuemetrics'@'localhost';"
mysql -uqueuemetrics -pjavadude queuemetrics < /usr/local/queuemetrics/qm-current/WEB-INF/README/queuemetrics_sample.sql

uniloader \
	pbxinfo \
	--mode "syncqm" \
	--uri "http://127.0.0.1:8080/queuemetrics" \
	--login "demoadmin" \
	--pass "demo" \
	--all-queues "1" \
	freepbx \
	--dburi "localhost/asterisk" \
	--login "root" \
	--pwd ""

AMI_PASSWORD="$( < /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-15} )"

cat > /etc/asterisk/manager_queuemetrics.conf <<EOF
; generated by QueueMetrics Espresso
[queuemetrics]
secret = ${AMI_PASSWORD}
deny = 0.0.0.0/0.0.0.0
permit= 127.0.0.1/255.255.255.0
read = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate,message
write = system,call,log,verbose,command,agent,user,config,command,dtmf,reporting,cdr,dialplan,originate,message
writetimeout = 5000
EOF

test -z "$( grep "manager_queuemetrics.conf" /etc/asterisk/manager.conf )" && echo "#include manager_queuemetrics.conf" >> /etc/asterisk/manager.conf
test -z "$( grep "extensions_queuemetrics.conf" /etc/asterisk/extensions_custom.conf )" && echo "#include extensions_queuemetrics.conf" >> /etc/asterisk/extensions_custom.conf
cp /usr/local/queuemetrics/qm-current/WEB-INF/mysql-utils/extensions-examples/extensions_queuemetrics_18.conf /etc/asterisk/extensions_queuemetrics.conf
sed '/exten => 28/ s=SIP=PJSIP=' -i /etc/asterisk/extensions_queuemetrics.conf
asterisk -rx "core reload"

uniloader cfgfile put --forced-replacement 1 -p "callfile.agentlogin.enabled" -v "false"
uniloader cfgfile put --forced-replacement 1 -p "callfile.agentlogoff.enabled" -v "false"
uniloader cfgfile put --forced-replacement 1 -p "callfile.dir" -v "tcp:queuemetrics:${AMI_PASSWORD}@127.0.0.1"
uniloader cfgfile put --forced-replacement 1 -p "callfile.transfercall.enabled" -v "true"
uniloader cfgfile put --forced-replacement 1 -p "cluster.freepbx.callfile.dir" -v "tcp:queuemetrics:${AMI_PASSWORD}@127.0.0.1"
uniloader cfgfile put --forced-replacement 1 -p "cluster.freepbx.manager" -v "tcp:queuemetrics:${AMI_PASSWORD}@127.0.0.1"
uniloader cfgfile put --forced-replacement 1 -p "cluster.freepbx.monitored_calls" -v "/var/spool/asterisk/monitor/"
uniloader cfgfile put --forced-replacement 1 -p "cluster.freepbx.queuelog" -v "sql:P001"
uniloader cfgfile put --forced-replacement 1 -p "cluster.servers" -v "freepbx"
uniloader cfgfile put --forced-replacement 1 -p "default.alwaysLogonUnpaused" -v "true"
uniloader cfgfile put --forced-replacement 1 -p "default.crmapp" -v "https://www.queuemetrics.com/sample_screen_pop.jsp?agent=[A]\&unique=[U]"
uniloader cfgfile put --forced-replacement 1 -p "default.exitOnAgentDumpSysCompat" -v "false"
uniloader cfgfile put --forced-replacement 1 -p "default.hotdesking" -v "86400"
uniloader cfgfile put --forced-replacement 1 -p "default.monitored_calls" -v "/var/spool/asterisk/monitor/"
uniloader cfgfile put --forced-replacement 1 -p "default.queue_log_file" -v "sql:P001"
uniloader cfgfile put --forced-replacement 1 -p "default.rewriteLocalChannels" -v "true"
uniloader cfgfile put --forced-replacement 1 -p "default.synchronizer_mode" -v "CR_UPD_USR"
uniloader cfgfile put --forced-replacement 1 -p "platform.directami.extension" -v "PJSIP/\${num}"
uniloader cfgfile put --forced-replacement 1 -p "platform.directami.outbound.enabled" -v "true"
uniloader cfgfile put --forced-replacement 1 -p "realtime.agent_autoopenurl" -v "true"
uniloader cfgfile put --forced-replacement 1 -p "realtime.agent_button_1.enabled" -v "false"
uniloader cfgfile put --forced-replacement 1 -p "realtime.agent_button_2.enabled" -v "false"
uniloader cfgfile put --forced-replacement 1 -p "realtime.agent_button_3.enabled" -v "false"
uniloader cfgfile put --forced-replacement 1 -p "realtime.agent_button_4.enabled" -v "false"
uniloader cfgfile put --forced-replacement 1 -p "realtime.ajaxPollingDelay" -v "5"
uniloader cfgfile put --forced-replacement 1 -p "realtime.max_bytes_agent" -v "65000"
uniloader cfgfile put --forced-replacement 1 -p "realtime.members_only" -v "false"
uniloader cfgfile put --forced-replacement 1 -p "realtime.refresh_time" -v "10"
uniloader cfgfile put --forced-replacement 1 -p "realtime.useActivePolling" -v "true"
uniloader cfgfile put --forced-replacement 1 -p "realtime.useRowCache" -v "true"

uniloader user --login queuemetrics --pwd javadude add-class -c ADMIN -k "MON_AUDIO MON_WHISPER MON_BARGE MON_VNC MON_IM"


# IVR
if [ ! -d /var/www/html/admin/modules/queuemetrics ]
then
	WORKDIR="$( mktemp -d XXXXXXXX )"
	cd "${WORKDIR}"
	wget "https://git.freepbx.org/rest/api/latest/projects/FPBXCN/repos/queuemetrics/archive?format=zip" -O queuemetrics.zip
	unzip queuemetrics.zip
	rm queuemetrics.zip
	cd ..
	mv "${WORKDIR}" /var/www/html/admin/modules/queuemetrics
	chown -R asterisk:asterisk /var/www/html/admin/modules/queuemetrics
	fwconsole ma install queuemetrics
fi

cat > /etc/sysconfig/uniloader <<EOF
QUEUELOG=/var/log/asterisk/queue_log
LOGFILE=/var/log/asterisk/uniloader.log
LOCKFILE=/var/lock/subsys/uniloader
PIDFILE=/run/uniloader.pid

# On-premise QueueMetrics instance
URI="mysql:tcp(127.0.0.1:3306)/queuemetrics?allowOldPasswords=1"
LOGIN=queuemetrics
PASS=javadude
TOKEN=P001
EOF

/etc/init.d/uniloader start