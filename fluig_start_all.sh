#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_start_all.sh
## Author : Kung <kung.wang@totvs.com>, Denny <denny.zhang@totvs.com>
## Description :
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-12 11:02:10>
##-------------------------------------------------------------------
sleep_seconds=${1:-10}
log_file=${2:-"/var/log/fluig.log"}

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

log "========= Start the whole service stack. It shall take 1~2 min ============"
log "start keystore"
/etc/init.d/keystore start
sleep $sleep_seconds

log "start search"
/etc/init.d/search start
sleep $sleep_seconds

log "start rest"
/etc/init.d/rest start
sleep $sleep_seconds

log "start rmi"
/etc/init.d/rmi start
sleep $sleep_seconds

log "start adsync"
/etc/init.d/adsync start
sleep $sleep_seconds

log "start tomcat7"
/etc/init.d/tomcat7 start
sleep $sleep_seconds

log "start $apache_name"
/etc/init.d/$apache_name start

log "========== Make sure all processes are up ==============="
log "ps -ef | grep $apache_name"
ps -ef | grep $apache_name | grep -v grep

log "ps -ef | grep tomcat"
ps -ef | grep tomcat | grep -v grep

log "ps -ef | grep cloudpass"
ps -ef | grep cloudpass | grep -v grep
log "================= ps process ============================"
## File : fluig_start_all.sh ends
