#!/bin/sh

cd && cd

if [ -d $1 ]
#if [ -d /usr/share/nginx ]
then
	exit 0
fi

if [ !-d nginx-1.8.1 ]
then
	tar zxvf nginx-1.8.1.tar.gz
fi

cd nginx-1.8.1

#./configure --prefix=/usr/local/nginx --conf-path=/etc/nginx/nginx.conf --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_geoip_module
./configure --prefix=$1 --conf-path=$2/nginx.conf --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_geoip_module
#./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_geoip_module --with-http_sub_module --add-module=modules/headers-more-nginx-module --add-module=modules/lua-nginx-module --add-module=modules/memc-nginx-module --add-module=modules/nginx-module-vts --add-module=modules/ngx_cache_purge --add-module=modules/ngx_devel_kit --add-module=modules/set-misc-nginx-module --add-module=modules/srcache-nginx-module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_stub_status_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --with-ld-opt=' -Wl,-E'

make && make install

