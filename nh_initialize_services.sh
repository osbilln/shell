#!/bin/bash -e
##-------------------------------------------------------------------
## File : nh_initialize_services.sh
## Author : Bill Nguyen
## Description :
## --
## Created : <2014-09-15>
## Updated: Time-stamp: <2014-09-24 11:01:33>
##-------------------------------------------------------------------
. /etc/profile
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function ensure_is_root() {
    # Make sure only root can run our script
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root." 1>&2
        exit 1
    fi
}

ensure_is_root

flagfile=${1?}
sleep_seconds=${2:-5}

if [ -f $flagfile ]; then
    log "Error to initialize rmi. $flagfile already exists, which means it's already initialized"
    exit 1
fi

log "Init nh services. The whole process shall take ~5 min"
# TODO: make nh_stop_all.sh and nh_start_all.sh shorter
nh_stop_all.sh $sleep_seconds || true
# TODO: make sure all services are down

rm -rf /cloudpass/backend/build/bin/CloudpassKeystore
/etc/init.d/keystore start
# TODO: make sure keystore running

# tail /data/nhidentity-logs/keystore.log
# TODO: better way
sleep $sleep_seconds

# rmistart_purge.sh
nohup_log="/tmp/rmistart_purge_nohup.log"
cd /cloudpass/backend/build/bin  && nohup ./rmistart_purge.sh > $nohup_log &
# TODO: better way
log "sleep a while for rmi purge"
sleep 30

if tail $nohup_log | grep 'thread finished, releasing the lock now'; then
    pid=$(ps ax | grep rmistart_purge | grep -v grep | awk '{print $1}')
    if [ -n "$pid" ]; then
        echo $pid | xargs kill -15 2>&1
        sleep 2 # TODO better way
    fi

    pid=$(ps ax | grep 'ServerStart.jar purge' | grep -v grep | awk '{print $1}')
    if [ -n "$pid" ]; then
        echo $pid | xargs kill -15 2>&1
        sleep 2 # TODO better way
    fi
else
    log "Error to run rmistart_purge.sh"
    exit 1
fi

# TODO: grep "thread finished, releasing the lock now!"

# TODO Should stop rmistart_purge.sh, when it's done

nh_stop_all.sh $sleep_seconds; nh_start_all.sh $sleep_seconds

# If status is not up, quit with failure
nh_status_all.sh

# When initialization is done, create a flagfile
touch $flagfile

## File : nh_initialize_services.sh ends