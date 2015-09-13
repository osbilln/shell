#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_watch_dir.sh
## Author : Kung <kung.wang@totvs.com>, Denny <denny.zhang@totvs.com>
## Description :
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-08 22:07:14>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

# Before run the script, make sure inotify-tools package is installed

# Example: fluig_watch_dir.sh
# Example: fluig_watch_dir.sh /var/log/tomcat7
# Example: fluig_watch_dir.sh /var/log/apache2

log_dir=${1:-"/data/fluigidentity-logs"}

cd $log_dir
log "monitor changes to $log_dir"
while str=$(inotifywait -e modify . 2>/dev/null); do
    logfile=$(echo "$str" | awk -F' ' '{print $3}');
    echo -n "[$logfile] ";
    tail -1 "$logfile";
done

## File : fluig_watch_dir.sh ends
