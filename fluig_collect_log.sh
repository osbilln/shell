#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_collect_log.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description : Before touching anything, collect all related log files
## --
## Created : <2014-09-03>
## Updated: Time-stamp: <2014-09-08 10:14:05>
##-------------------------------------------------------------------
############################ Helper functions ###################################
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n" >> $log_file
}

function get_backup_chroot_dir()
{
    local backup_dir=${1?}
    local current_timestamp=`date +'%Y-%m-%d_%H-%M-%S'`
    echo "$backup_dir/$current_timestamp"
}

function backup_dir()
{
    local dir_src=${1?}
    local dir_dst=${2?}
    for f in `find $dir_src -mtime -$BACKUP_FILES_WITHIN_DAYS | grep '.log$'`; do
        if [ "$f" != "$dir_src" ]; then
            if [ -d $f ]; then
                backup_dir $f $dir_dst
            else
                backup_file $f $dir_dst
            fi
        fi
    done
}

function backup_file()
{
    local file_src=${1?}
    local file_dst=${2?}
    local dst_dir="$file_dst/$(dirname $file_src)"
    mkdir -p $dst_dir
    file_size=$(stat $file_src | grep ' Size:' | awk -F": " '{print $2}' | awk -F"\t" '{print $1}')
    if $FULL_BACKUP; then
        /bin/cp $file_src "$dst_dir/$(basename $file_src)"
    else
        if [ $file_size -gt $LARGE_FILE_SIZE ]; then
            # handle large log files
            tail -n $TAIL_COUNT $file_src > "$dst_dir/tail_$(basename $file_src)"
        else
            /bin/cp $file_src "$dst_dir/$(basename $file_src)"
        fi
    fi
}

#################################################################################
# Example: ./fluig_collect_log.sh

backup_dir=${1:-"/data/log_backup"}
log_file=${2:-"/var/log/fluig_collect_log.log"}

# Note: If logfiles is larger than $LARGE_FILE_SIZE, we will only backup the last $TAIL_COUNT lines
LARGE_FILE_SIZE=524288000 # 500MB
TAIL_COUNT=500000
FULL_BACKUP=true
# Only backup files changed in recent days
BACKUP_FILES_WITHIN_DAYS=2

declare -a backup_list=(
    "/var/log/tomcat7"
    "/var/log/apache2"
    "/data/fluigidentity-logs/"
    "/cloudpass/backend/build/bin/cloudpass_logs/server.log")

function collect_log()
{
    local backup_chroot_dir=$(get_backup_chroot_dir $backup_dir)

    log "Collect critical log files to $backup_chroot_dir"
    for log_src in "${backup_list[@]}"; do
        if [ -d $log_src ]; then
            backup_dir $log_src $backup_chroot_dir
        else
            if [ -f $log_src ]; then
                # Notice:
                backup_file $log_src $backup_chroot_dir
            else
                log "Error: invalid files or not exists"
            fi
        fi
    done;
    log "log file collection is done"
}

collect_log

## File : fluig_collect_log.sh ends
