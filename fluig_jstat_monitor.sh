#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_jstat_monitor.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-04>
## Updated: Time-stamp: <2014-09-22 15:11:34>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

pattern_of_process="rest.jar"
pid=$(ps ux | grep $pattern_of_process | grep -v grep | awk -F' ' '{print $2}')

if [ -z "$pid" ]; then
    log "Can't find process of $pattern_of_process"
    exit 1
else
    log "run jstat"
    while true; do
        jstat -gc $pid 1000 1
        sleep 1
        echo -e "\n"
    done
fi
## File : fluig_jstat_monitor.sh ends
