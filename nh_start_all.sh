#!/bin/bash -e
##-------------------------------------------------------------------
## File : nh_start_all.sh
# Author : Bill <billn@naehas.com>
## Description :
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-24 11:12:05>
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

log "========= Start the whole service stack. It shall take 1~2 min ============"
service_start "keystore" $wait_seconds 18087

service_start "search" $wait_seconds 18084

service_start "rest" $wait_seconds 18090

service_start "rmi" $wait_seconds 11111

service_start "adsync" $wait_seconds 18080

service_start "tomcat7" $wait_seconds 8009

service_start $apache_name $wait_seconds 443

log "========== Make sure all processes are up ==============="
log "ps -ef | grep $apache_name"
ps -ef | grep $apache_name | grep -v grep

log "ps -ef | grep tomcat"
ps -ef | grep tomcat | grep -v grep

log "ps -ef | grep cloudpass"
ps -ef | grep cloudpass | grep -v grep
log "================= ps process ============================"
## File : nh_start_all.sh ends
