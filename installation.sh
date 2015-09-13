#!/bin/bash -e
##-------------------------------------------------------------------
## File : installation.sh
## Author : dennyzhang.com <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-06-15>
## Updated: Time-stamp: <2014-07-12 14:39:08>
##-------------------------------------------------------------------
. utility.sh
ensure_is_root

grep -i "centos" /etc/issue -i -q && install="yum install"; os="centos"
grep -i "debian" /etc/issue -i -q && install="apt-get -y install"; os="debian"
grep -i "ubuntu" /etc/issue -i -q && install="apt-get -y install"; os="debian"

ensure_is_root
if [ "$os" = "debian" ]; then
    which easy_install || $install python-setuptools
fi;

easy_install pip
pip_install flask
$install lsof
    
## File : installation.sh ends
