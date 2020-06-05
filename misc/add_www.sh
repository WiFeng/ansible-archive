#!/bin/sh

useradd www

mkdir /home/www/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAIZEx/bwyIKDCJlCO8CCZRHnMkWLy8a3IEedp4aSRVSCFqZ6zYF8A4lxiBo3YQR/L8XxiqgOzKUTOJW2Kq2MChW8cRfT6ev5LzIhmXh3lk00gFjzwHMz3rJuAW+rtiXSnpYXw+BcY5poBSxu04gPG9Qeb6rQ1VafwmNbp8hOIlD4DZkFU75Uy7raZaLfGDObbK/gUiyhtjjprzEbenDTv5SpuLA8uk3r3Q3K0ukkv0Cx9AeLkAjdIGDiY8PBZ+pt46BGP/OEggGqfrHomF8N7yiFC7x03nhGtD6wBvANLCiG/2U3HBy/On7HGRKqPNCDmVsvd5lXJxyjSbjgY5RYQ== www@vm-29-164-pro01-zwdx.bj-cn.vpc.letv.cn" >> /home/www/.ssh/authorized_keys

chown -R www:www /home/www/.ssh/

chmod 700 /home/www/.ssh
chmod 600 /home/www/.ssh/authorized_keys
