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

./configure --prefix=$prefix 

make && make install

ln -s -f $prefix/bin/convert /usr/bin/convert
ln -s -f $prefix/bin/animate /usr/bin/animate

