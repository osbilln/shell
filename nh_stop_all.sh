#!/bin/bash
##-------------------------------------------------------------------
## File : nh_stop_all.sh
# Author : Bill <billn@naehas.com>
## Description :
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-24 09:12:08>
##-------------------------------------------------------------------
wait_seconds=${1:-10}
log_file=${2:-"/var/log/nh.log"}

. /usr/lib/nh_devops_lib.sh

ensure_is_root
os_version=$(os_release)

apache_name=""
if [ "$os_version" == "ubuntu" ]; then
    apache_name="apache2"
elif [ "$os_version" == "redhat" ] || [ "$os_version" == "centos" ]; then
    apache_name="httpd"
else
    log "Error: Not supported version"
fi

log "========= Stop down the whole service stack. It shall take 1~2 min ============"
service_stop $apache_name $wait_seconds

service_stop "tomcat7" $wait_seconds

service_stop "rest" $wait_seconds

service_stop "search" $wait_seconds

service_stop "adsync" $wait_seconds

service_stop "rmi" $wait_seconds

service_stop "keystore" $wait_seconds

log "========== Make sure all processes are down ============="
log "ps -ef | grep $apache_name"
ps -ef | grep $apache_name | grep -v grep

log "ps -ef | grep tomcat"
ps -ef | grep tomcat | grep -v grep

log "ps -ef | grep cloudpass"
ps -ef | grep cloudpass | grep -v grep

log "========================================================="
## File : nh_stop_all.sh ends
