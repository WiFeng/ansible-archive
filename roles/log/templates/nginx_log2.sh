#!/bin/bash
####################说明#######################
##只修改配置信息变量值即可  
##cronatb 命令:
##00 00 * * * /bin/bash  /letv/sh/nginx_log.sh
###############################################

##############定义配置信息#############
#待推送日志的全路径

log_arr=(access.log
	error.log
	php_errors.log
	php-fpm.log
	www.log.slow
	phpmessages
)

cfg_log_app={{cfg_log_app}}

#App服务器编号 (1、2..) 计算sleep时间使用。 例: vcs有4台服务器，则4台服务器上值分别标记为 1、2、3、4
cfg_app_id=1

mod=10.122.148.131/logbackup

y=$(date -d "yesterday" +"%Y")
m=$(date -d "yesterday" +"%m")
d=$(date -d "yesterday" +"%d")

remote_path=/$y/$m/$d/
for myline in ${log_arr[@]}
do
     if [[ -f "/letv/logs/nginx/$myline" || -f "/letv/logs/php/$myline" || -f "/letv/logs/$myline" ]];then

     mod_path=/letv/tmp/$cfg_log_app/$y/$m/$d/
     mkdir -p $mod_path
     ip=`/sbin/ifconfig eth0 | grep 'inet addr' | grep -v '127.0.0.1' | awk '{print $2;}' | awk -F':' '{print $2;}'`
     log_name="$cfg_log_app.$myline.$y$m$d.$ip"
     
     remote_path=/$y/$m/$d/$log_name.gz
     real_remote_path=rsync://$mod/$cfg_log_app$remote_path
     is_exist=`rsync -v  $real_remote_path|grep -c  $log_name `  
     if [ $is_exist = 1 ];then
        echo "the file is already in remote host"
        continue
     fi
          

     mv /letv/logs/nginx/$myline $mod_path$log_name
     mv /letv/logs/php/$myline $mod_path$log_name
     mv /letv/logs/$myline $mod_path$log_name
     gzip $mod_path$log_name
     else
       echo "$myline no file"
       continue
     fi
 
done

  # kill -HUP `cat /usr/local/nginx/logs/nginx.pid`
  # kill  -USR1 `cat /usr/local/php/var/run/php-fpm.pid`

kill -HUP `cat /var/run/nginx.pid`
kill -USR1 `cat /var/run/php-fpm.pid`

cp -r /letv/tmp/$cfg_log_app  /letv/logs/archive
/usr/bin/rsync -vzirtopg /letv/tmp/$cfg_log_app rsync://$mod
rm -fr /letv/tmp/$cfg_log_app

if [ $(date -d "today" +"%d") = 02 ];then
    y=$(date -d "now" +"%Y")
    last_month=$(date -d "last-month" +"%m")
    last_month_local_path=/letv/logs/archive/$cfg_log_app/$y/$last_month/
    rm -rf $last_month_local_path
    # mv $last_month_local_path /letv/logs/archive/
fi
