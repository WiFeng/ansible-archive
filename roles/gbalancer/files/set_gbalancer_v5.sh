#!/bin/bash
THEPORT=$1
MONITOR_PASS=$2
DB_IP1=$3
DB_IP2=$4
DB_IP3=$5
CHOOSE_MODEL=$6
 
#remove gbalancer
GBALANCER_PORT=$1
IS_REMOVE=$2
if [ "$IS_REMOVE" = "remove" ]
then
GB_IS_RUN=`ps -ef| grep gbalancer|grep ${GBALANCER_PORT}configuration.json|wc -l`
if [ $GB_IS_RUN = 1 ]
then
#remove gbalancer on monit config
sed -i "/${GBALANCER_PORT}gbalancer/d" /etc/services.cfg 
#reload monit
monit reload
#kill gbalancer process
ps -ef| grep gbalancer|grep ${GBALANCER_PORT}configuration.json|awk '{print $2}'|xargs kill -9
#remove config file
rm -rf /etc/gbalancer/${GBALANCER_PORT}configuration.json
rm -rf /etc/init.d/${GBALANCER_PORT}gbalancer 
echo ${GBALANCER_PORT}'gbalancer remove success'
else
echo ${GBALANCER_PORT}'gbalancer is not run'
fi
 
else
#install gbalancer
if [[ ! $1 ]] || [[ ! $2 ]] || [[ ! $3 ]] || [[ ! $4 ]] || [[ ! $5 ]] 
then
echo -e "Missing parameters!!\nplease check you input parameters!!"
else
CHECK_PORT1=`/bin/ps -ef| grep ${THEPORT}|grep gbalancer|grep -v grep | grep -v $0 | wc -l`
CHECK_PORT2=`/bin/netstat -nap| awk '{print $4}' | grep :${THEPORT}$ |wc -l`
if [ $CHECK_PORT1 -gt 0 -o $CHECK_PORT2 -gt 0 ]
then
echo ${THEPORT}" PORT has used!!"
echo "ps="${CHECK_PORT1}" netstat="${CHECK_PORT2}
else
if [ ! $CHOOSE_MODEL ] 
then
  CHOOSE_MODEL=" "
else
if [ $CHOOSE_MODEL = 0 ]  
then
  CHOOSE_MODEL=" "
elif [ $CHOOSE_MODEL = 1 ]
then
  CHOOSE_MODEL=" -failover=true -shuffle=false  "
elif [ $CHOOSE_MODEL = 2 ]
then
  CHOOSE_MODEL=" --tunnels=2  "
fi
fi
if [ `rpm -qa | grep gbalancer |wc -l` = 0 ]
then
yum install -y mysql
/usr/bin/wget -P /usr/bin/ ftp://ftp.db.lecloud.com:21/plugin/gbalancer --ftp-user=user_r --ftp-password=ObVU7rDi
chmod 755 /usr/bin/gbalancer
fi
#gbalancer init file
cat > /etc/init.d/${THEPORT}gbalancer << EOF
#!/bin/sh
#
# gbalancer - this script starts and stops the gbalancer daemin
#
# chkconfig: - 86 16
# processname: gbalancer
# config:     /etc/gbalancer.json
# pidfile:    /var/run/gbalencer.pid
set -e
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="gbalancer${THEPORT} deamon"
NAME=gbalancer
NAME1=${THEPORT}gbalancer
DAEMON=/usr/bin/\$NAME
SCRIPTNAME=/etc/init.d/\$NAME1
PORT=${THEPORT}
PROCESS="/usr/bin/gbalancer --config=/etc/gbalancer/\$PORT""configuration.json"
# If the daemon file is not found, terminate the script.
test -x \$DAEMON || exit 0
d_start() {
   if [ \`ps aux|grep "\$PROCESS" |grep -v grep|wc -l\` -eq 1  ];then
      echo "\$DESC:is running"
   else
      nohup  \$DAEMON --config=/etc/gbalancer/"\$PORT"configuration.json $CHOOSE_MODEL --daemon  &
      [ \$? -eq 0 ] && echo "\$DESC:is ok" || echo "\$DESC:is wrong"
   fi
}
d_stop() {
if [ \`ps aux|grep "\$PROCESS" |grep -v grep|wc -l\` -ge 1  ];then
   for ((i=1;i<=10;i++));
   do
      kill -9 \`ps aux|grep "\$PROCESS" |grep -v grep |awk '{print \$2}'\`
      if [ \`ps aux|grep  "\$PROCESS" |grep -v grep|wc -l\` -eq 0  ];then
         echo "\$DESC:is stop"
         break
      fi  
   done
else
   echo "\$DESC:is stop"
fi
}
case "\$1" in
   start)
      d_start
      ;;
   stop)
      echo -e "Stopping \$NAME1"
      d_stop
      ;;
   status)
      if [  \`ps aux|grep "\$PROCESS" |grep -v grep|wc -l\` -eq 1 ];then
         echo -e "\$DESC: is runging"
      else
         echo -e "\$DESC: is stop"
      fi
   ;;
   restart)
      echo -n "Restarting \$NAME1"
      d_stop
      sleep 2
      d_start
      ;;
   *)
      echo "Usage: \$SCRIPTNAME {start|stop|restart|status}" >&2
      exit 3
      ;;
esac
exit 0
EOF
      
chmod a+x /etc/init.d/${THEPORT}gbalancer
 
if [ ! -d "/etc/gbalancer" ]
then
  mkdir /etc/gbalancer
fi
#gbalancer set file
cat > /etc/gbalancer/${THEPORT}configuration.json << EOF
{
    "User": "monitor",
    "Pass": "${MONITOR_PASS}",
    "Addr": "127.0.0.1",
    "Port": "${THEPORT}",
    "Backend": [
        "${DB_IP1}:3306",
        "${DB_IP2}:3306",
        "${DB_IP3}:3306"
    ] 
}
EOF
#is exists services.cfg
if [ ! -f "/etc/monitrc" ]
then
  echo "include /etc/services.cfg" >> /etc/monitrc
else
  if [ `grep "include /etc/services.cfg" /etc/monitrc|wc -l` = 0 ]
  then
    echo "include /etc/services.cfg" >> /etc/monitrc
  fi
fi
if [ `grep "${THEPORT}gbalancer" /etc/services.cfg|wc -l` = 0 ]
then
cat >> /etc/services.cfg << EOF
check process ${THEPORT}gbalancer MATCHING '/usr/bin/gbalancer --config=/etc/gbalancer/${THEPORT}configuration.json '
    start program = "/etc/init.d/${THEPORT}gbalancer start"
    stop  program = "/etc/init.d/${THEPORT}gbalancer stop"
EOF
fi
monit -t
monit reload
sleep 3
mysql -umonitor -p${MONITOR_PASS} -h127.0.0.1 -P${THEPORT} -Bse "select version();"
if [ $? -eq 0 ]
then
echo "gbalancer configure is success!"
else
echo "gbalancer configure is fail!"
fi
fi
fi
fi
