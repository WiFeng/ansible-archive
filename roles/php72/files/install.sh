#!/bin/sh

prefix=$1
package=$2

cd && cd

if [ -d $prefix ]
then
	exit 0
fi

if [ ! -d $package ]
then
	tar zxvf ${package}.tar.gz
fi

cd $package

## --with-mysql=/usr
./configure  --prefix=$prefix --enable-shmop --enable-sysvmsg --enable-sigchild --enable-sysvshm --enable-gd-native-ttf --enable-sysvsem --enable-mbstring --enable-mbregex --enable-bcmath --enable-xml --enable-sockets --enable-inline-optimization --enable-soap --disable-rpath --with-libxml-dir=/usr --with-iconv-dir=/usr --with-config-file-path=$prefix/etc/ --with-curl --with-mhash --with-gd --with-zlib --with-jpeg-dir=/usr/ --with-png-dir=/usr/ --with-freetype-dir=/usr --with-gettext --with-openssl --with-mcrypt --with-mysql --with-pdo-mysql --with-mysqli=/usr/bin/mysql_config --with-readline --with-mcrypt=/usr/local/libmcrypt --enable-fpm --enable-zip --enable-pcntl --enable-opcache

make && make install

