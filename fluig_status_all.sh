#!/bin/bash
##-------------------------------------------------------------------
## File : fluig_status_all.sh
## Author : Kung <kung.wang@totvs.com>, Denny <denny.zhang@totvs.com>
## Description :
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-12 11:28:06>
##-------------------------------------------------------------------
log_file=${1:-"/var/log/fluig.log"}

function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n" >> $log_file
}

function ensure_is_root() {
    # Make sure only root can run our script
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root." 1>&2
        exit 1
    fi
}

function os_release() {
    set -e
    distributor_id=$(lsb_release -a 2>/dev/null | grep 'Distributor ID' | awk -F":\t" '{print $2}')
    if [ "$distributor_id" == "RedHatEnterpriseServer" ]; then
        echo "redhat"
    elif [ "$distributor_id" == "Ubuntu" ]; then
        echo "ubuntu"
    else
        echo "ERROR: Not supported OS"
    fi
}

function service_status()
{
    service_name=${1?}
    log "Check $service_name"
    /etc/init.d/$service_name status
    echo ""
}

function tail_log_dir()
{
    log_dir=${1?}
    tail_count=${2:-3}
    log "Tail $log_dir"
    for f in `find $log_dir -name '*.log' -type f`; do
        echo -e "\n----------------<$f> start----------------";
        tail -n $tail_count "$f";
        echo -e "\n----------------<$f> end----------------\n";
    done
    echo ""
}

ensure_is_root
os_version=$(os_release)

apache_name=""
if [ "$os_version" == "ubuntu" ]; then
    apache_name="apache2"
elif [ "$os_version" == "redhat" ]; then
    apache_name="httpd"
else
    log "Error: Not supported version"
fi

log "========= Check status of all fluig services ============"
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
tail_log_dir "/data/fluigidentity-logs" 2

log "================= ps process ============================"
log "ps -ef | grep $apache_name"
ps -ef | grep $apache_name | grep -v grep

log "ps -ef | grep tomcat"
ps -ef | grep tomcat | grep -v grep

log "ps -ef | grep cloudpass"
ps -ef | grep cloudpass | grep -v grep

log "========================================================="
## File : fluig_status_all.sh ends
