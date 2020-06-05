#!/bin/sh

useradd www

mkdir /home/www/.ssh

# echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtAIZEx/bwyIKDCJlCO8CCZRHnMkWLy8a3IEedp4aSRVSCFqZ6zYF8A4lxiBo3YQR/L8XxiqgOzKUTOJW2Kq2MChW8cRfT6ev5LzIhmXh3lk00gFjzwHMz3rJuAW+rtiXSnpYXw+BcY5poBSxu04gPG9Qeb6rQ1VafwmNbp8hOIlD4DZkFU75Uy7raZaLfGDObbK/gUiyhtjjprzEbenDTv5SpuLA8uk3r3Q3K0ukkv0Cx9AeLkAjdIGDiY8PBZ+pt46BGP/OEggGqfrHomF8N7yiFC7x03nhGtD6wBvANLCiG/2U3HBy/On7HGRKqPNCDmVsvd5lXJxyjSbjgY5RYQ== www@vm-29-164-pro01-zwdx.bj-cn.vpc.letv.cn" >> /home/www/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5VBOd6lAO4CKJyTHQooo6vP4YdD84cfZZs+kdSmiM/HZ7W4jtW6tx8rHDNFBx8mGPqD8BjLs57xO1GlTNgAFQEDdSgrUCh8w+XX83bcBQMMRhchRYMWhBOpkbhLmuIomFlYcVj/m2cEjUSyeuqPoePtvutAkOsLu7/yMEuf4ysp/Asjg3+8mXHZ8DI/f+cETk1VR8dSwhGaVyfgo6V6SufEq1rf+qW3BWi4FJEMgQ1JXuou0prALPchBPp+OLaooios+9wkhow6Yf6cM8llnCI5//M32dRXdeTIWAZefXzvHChMj8x7U8u5Wlodz0JHTvxZCz0afHDkfcquU9/zYFw== www@vm-10-112-43-1" >> /home/www/.ssh/authorized_keys

chown -R www:www /home/www/.ssh/

chmod 700 /home/www/.ssh
chmod 600 /home/www/.ssh/authorized_keys
