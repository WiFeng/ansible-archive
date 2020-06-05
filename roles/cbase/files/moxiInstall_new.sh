#/bin/bash

# Last modified: 20170803
# Author: diaowenbo
# Mail: diaowenbo@le.com
# last change: 20161201


moxi_install() {
#grep -q 'pkg-repo.oss.letv.com' /etc/yum.repos.d/letv-pkgs.repo
#
#if [ $? -ne 0 ]; then
#cat <<EOF > /etc/yum.repos.d/letv-pkgs.repo
## letv-updates.repo
##
## Pkgs updates for letv internal systems
##
##
#[letv-updates]
#name=CentOS-$releasever - letv-updates
#baseurl=http://115.182.51.149/pkgs/centos6/updates/
#gpgcheck=0
#
#[letv-extras]
#name=CentOS-$releasever - letv-extras
#baseurl=http://115.182.51.149/pkgs/centos6/extras/
#gpgcheck=0
#
#[letv-drivers]
#name=CentOS-$releasever - letv-drivers
#baseurl=http://115.182.51.149/pkgs/centos6/drivers/
#gpgcheck=0
#
#[staging]
#name=CentOS-$releasever - staging
#baseurl=http://115.182.51.149/pkgs/centos6/staging/
#enabled=0
#gpgcheck=0
#EOF
#
#fi

curl -o /etc/yum.repos.d/leCldPC.repo http://10.110.176.250/cbase/leCldPC.repo

yum --disablerepo=* --enablerepo=leCld* install moxi -y

}


monit() {

grep -q 'include /etc/services.cfg' /etc/monitrc || echo -e "\ninclude /etc/services.cfg" >> /etc/monitrc

cat <<EOF >> /etc/services.cfg

check process moxi$MOXI_PORT
        with pidfile "/var/run/moxi/$MOXI_NAME.pid"
        start program = "$MOXI_SERVICE start"
        stop program = "$MOXI_SERVICE stop"
        if totalmem > 1024 MB then restart
        every "* 3-6 * * *"
        depends on moxibase$MOXI_PORT

check process moxibase$MOXI_PORT
        with pidfile "/var/run/moxi/$MOXI_NAME.pid"
        start program = "$MOXI_SERVICE start"
        stop program = "$MOXI_SERVICE stop"
EOF

}

moxi()
{
cat <<EOF > $MOXI_CONF
# usr=MEMBASE_REST_USER,
# pwd=MEMBASE_REST_PSWD,

port_listen=$MOXI_PORT,

#default_bucket_name=default,

downstream_max=1024,
downstream_conn_max=4,
downstream_conn_queue_timeout=200,
downstream_timeout=5000,
wait_queue_timeout=200,
connect_max_errors=5,
connect_retry_interval=30000,
connect_timeout=400,
auth_timeout=100,

cycle=200

EOF

cat <<EOF > $MOXI_SYSCONFIG
# Change this with the cbase server info
# use {host1,host2} form for a multi-server configuration
CBASE_HOST='$CB_HOSTS'
CBASE_BUCKET='$CB_BUCKET'
CBASE_PWD='$CB_BUCKET'
USER="nobody"
MAXCONN="1024"
CPROXY_ARG="$MOXI_CONF"
OPTIONS=""

EOF


cat <<EOF > $MOXI_SERVICE
#! /bin/sh
#
# chkconfig: - 55 45
# description:  The moxi is a memchached proxy
# processname: moxi
# config: /etc/sysconfig/moxi

# Source function library.
. /etc/rc.d/init.d/functions

USER=nobody
MAXCONN=1024
CPROXY_ARG=$MOXI_CONF
MOXI_LOG=/var/log/$MOXI_NAME.log
OPTIONS=""
MOXI_LISTEN=127.0.0.1

MOXI_PID_FILE=/var/run/moxi/$MOXI_NAME.pid
MOXI_LOCK_FILE=/var/lock/subsys/$MOXI_NAME

if [ -f $MOXI_SYSCONFIG ];then
        . $MOXI_SYSCONFIG
fi

MOXI_SASL_PLAIN_USR="\$CBASE_BUCKET"
MOXI_SASL_PLAIN_PWD="\$CBASE_PWD"

if [ x"MOXI_SASL_PLAIN_USR" != x ]; then
        export MOXI_SASL_PLAIN_USR
fi

if [ x"MOXI_SASL_PLAIN_PWD" != x ]; then
        export MOXI_SASL_PLAIN_PWD
fi

# Check that networking is up.
if [ "\$NETWORKING" = "no" ]
then
        exit 0
fi

# if CPROXY_ARG is a config file reference check it's existance
if ([[ "/" < "\$CPROXY_ARG" ]] && [[ "\$CPROXY_ARG" < "0" ]]) || ([[ "." < "\$CPROXY_ARG" ]] && [[ "\$CPROXY_ARG" < "/" ]]); then
        if [ ! -f "\$CPROXY_ARG" ]; then
                echo "Misconfiguration! '\$CPROXY_ARG' is absent. See /usr/share/doc/moxi-1.8.0_8_g52a5fa8/examples/ for configuration examples. Aborting."
                exit 1
        fi
fi

RETVAL=0
prog="moxi"

start () {
        echo -n \$"Starting \$prog: "
        # insure that directory of pid file has proper permissions
        chown \$USER \`dirname \$MOXI_PID_FILE\`
        # We need "\," to handle the single CBASE_HOST case.
        STREAM=\`eval echo http://{\$CBASE_HOST\\,}:8091/pools/default/bucketsStreaming/\${CBASE_BUCKET:-default} | sed 's/ /,/g;s#,http://:8091.*\$##'\`

        daemon -5 /usr/bin/moxi -d -u \$USER -c \$MAXCONN -Z \$CPROXY_ARG -P \$MOXI_PID_FILE        \\
                -l "\$MOXI_LISTEN" -z \$STREAM -O \$MOXI_LOG \$OPTIONS
        RETVAL=\$?
        echo
        [ \$RETVAL -eq 0 ] && touch \$MOXI_LOCK_FILE
}
stop () {
        echo -n \$"Stopping \$prog: "
        killproc -p \$MOXI_PID_FILE moxi
        RETVAL=\$?
        echo
        if [ \$RETVAL -eq 0 ] ; then
            rm -f \$MOXI_LOCK_FILE
            rm -f \$MOXI_PID_FILE
        fi
                                                                                                      
}

restart () {
        stop
        start
}


# See how we were called.
case "\$1" in
  start)
        status -p \$MOXI_PID_FILE moxi >/dev/null 2>&1 && exit 0
        start
        ;;
  stop)
        status -p \$MOXI_PID_FILE moxi >/dev/null 2>&1 || exit 0
        stop
        ;;
  status)
        status -p \$MOXI_PID_FILE moxi
        ;;
  restart|reload)
        restart
        ;;
  condrestart)
        [ -f \$MOXI_LOCK_FILE ] && restart || :
        ;;
  *)
        echo \$"Usage: \$0 {start|stop|status|restart|reload|condrestart}"
        exit 1
esac

exit \$?

EOF

chmod 755 $MOXI_SERVICE

}


falconScript() {
	FS_Dir="/usr/local/LeMonitor/falcon-agent/plugin/Cbase/Moxi"
	FS_Shell="60_keyChk_$MOXI_PORT.sh"
	HttpGet="http://10.110.176.250/cbase/Utils/Cbase/Falcon"
	mkdir -p ${FS_Dir}
	curl -o ${FS_Dir}/${FS_Shell} ${HttpGet}/${FS_Shell}
	chmod 755 ${FS_Dir}/${FS_Shell}
	chown falcon.falcon -R /usr/local/LeMonitor/falcon-agent/plugin/Cbase
}


if [ $# -ne 3 ]; then
    echo "using $0 port bucket hosts(example:'10.10.2.30,10.10.2.31')"
    exit 1
fi


export MOXI_PORT=$1
export CB_BUCKET=$2
export CB_HOSTS=$3
export MOXI_CONF=/etc/moxi$1.conf
export MOXI_SYSCONFIG=/etc/sysconfig/moxi$1
export MOXI_SERVICE=/etc/init.d/moxi$1
export MOXI_NAME=moxi$1

if [ -f $MOXI_CONF ]; then
  echo "moxi port[$MOXI_PORT]'s conf [$MOXI_CONF] exists ,exit."
  exit 1
fi

if [ -f $MOXI_SYSCONFIG ]; then
  echo "moxi port[$MOXI_PORT]'s sysconfig [$MOXI_SYSCONFIG] exists ,exit."
  exit 1
fi

if [ -f $MOXI_SERVICE ]; then
  echo "moxi port[$MOXI_PORT]'s service [$MOXI_SERVICE] exists ,exit." 
  exit 1
fi


moxi_install
monit
moxi
falconScript

/usr/bin/monit reload
