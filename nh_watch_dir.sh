#!/bin/bash -e
##-------------------------------------------------------------------
## File : nh_watch_dir.sh
# Author : Bill <billn@naehas.com>
## Description :
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-24 09:23:03>
##-------------------------------------------------------------------
. /usr/lib/nh_devops_lib.sh

# Before run the script, make sure inotify-tools package is installed

# Example: nh_watch_dir.sh
# Example: nh_watch_dir.sh /var/log/tomcat7
# Example: nh_watch_dir.sh /var/log/apache2

log_dir=${1:-"/data/nhidentity-logs"}

cd $log_dir
log "monitor changes to $log_dir"
while str=$(inotifywait -e modify . 2>/dev/null); do
    logfile=$(echo "$str" | awk -F' ' '{print $3}');
    echo -n "[$logfile] ";
    tail -1 "$logfile";
done

## File : nh_watch_dir.sh ends
