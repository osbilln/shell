#!/bin/bash -e
##-------------------------------------------------------------------
## File : clean_cached_memory.sh
## Description :
## --
## Created : <2014-08-21>
## Updated: Time-stamp: <2014-08-21 15:58:06>
##-------------------------------------------------------------------
max_cached_kb=${1:-4194304} # By default, if more than 4GB memory is cached, we flush it.
logfile=${2:-"/var/log/nh_clean_cached_memory.log"}
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

log "Run clean_cached_memory.sh" >> $logfile
cached_kb=$(cat /proc/meminfo | grep '^Cached' | awk -F' ' '{print $2}')
if [ $cached_kb -gt $max_cached_kb ]; then
    log "cached memory is $cached_kb KB, which is more than $max_cached_kb. Flush the cached memory" >> $logfile
    sync; echo 3 > /proc/sys/vm/drop_caches
fi

## File : clean_cached_memory.sh ends
