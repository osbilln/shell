#!/bin/bash
##-------------------------------------------------------------------
## File : fluig_stop_all.sh
## Author : Kung <kung.wang@totvs.com>, Denny <denny.zhang@totvs.com>
## Description :
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-12 11:01:52>
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

log "========= Stop down the whole service stack. It shall take 1~2 min ============"
log "stop $apache_name"
/etc/init.d/$apache_name stop

log "stop tomcat7"
/etc/init.d/tomcat7 stop
sleep $sleep_seconds

log "stop rest"
/etc/init.d/rest stop
sleep $sleep_seconds

log "stop search"
/etc/init.d/search stop
sleep $sleep_seconds

log "stop adsync"
/etc/init.d/adsync stop
sleep $sleep_seconds

log "stop rmi"
/etc/init.d/rmi stop
sleep $sleep_seconds

log "stop keystore"
/etc/init.d/keystore stop

log "========== Make sure all processes are down ============="
log "ps -ef | grep $apache_name"
ps -ef | grep $apache_name | grep -v grep

log "ps -ef | grep tomcat"
ps -ef | grep tomcat | grep -v grep

log "ps -ef | grep cloudpass"
ps -ef | grep cloudpass | grep -v grep

log "========================================================="
## File : fluig_stop_all.sh ends
