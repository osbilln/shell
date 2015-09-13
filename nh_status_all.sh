#!/bin/bash
##-------------------------------------------------------------------
## File : nh_status_all.sh
# Author : Bill <billn@naehas.com>
## Description :
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-24 09:18:28>
##-------------------------------------------------------------------
log_file=${1:-"/var/log/nh.log"}

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

log "========= Check status of all nh services ============"
service_status keystore
service_status search
service_status rest
service_status rmi
service_status adsync
# TODO: initscript of tomcat in redhat should support status primitive
#service_status tomcat7
service_status hornetq
service_status $apache_name

log "================= tail logfile =========================="
tail_log_dir "/data/nhidentity-logs" 2

log "================= ps process ============================"
log "ps -ef | grep $apache_name"
ps -ef | grep $apache_name | grep -v grep

log "ps -ef | grep tomcat"
ps -ef | grep tomcat | grep -v grep

log "ps -ef | grep cloudpass"
ps -ef | grep cloudpass | grep -v grep

log "========================================================="
## File : nh_status_all.sh ends
