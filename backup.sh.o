#!/bin/bash -e
##-------------------------------------------------------------------
## File : nh_backup.sh $service_name
## Author : Bill <billn@naehas.com>
## Description :
## --
## Created : <2014-07-30>
## Updated: Time-stamp: <2014-09-24 09:20:08>
##-------------------------------------------------------------------
# Backup critical data for nh system:
#                  nh_backup.sh nagios
#                  nh_backup.sh neo4j
#                  nh_backup.sh all
# 
. /usr/lib/nh_devops_lib.sh

####################################################################
function backup_nagios_rrd()
{
    src_dir=${1:-"/usr/local/nagiosgraph/var/rrd"}
    dest_dir=${2:-"/home/backup/nagios_rrd"}
    log "Backup nagios rrd: from $src_dir to $dest_dir"

    mk_dir $dest_dir
    tar_dir $src_dir $dest_dir/$(current_time).tar.gz
}

function backup_keystore()
{
    log "Backup keystore"
    # TODO
    # /cloudpass/backend/build/bin/CloudpassKeystore
}

function backup_couchbase()
{
    dst_dir={2:-"/data/backup/couchbase"}
    server_url={3:-"http://localhost:8091"}

    log "Backup couchbase"
    if [[ $couchbase_password == "password" ]]; then
        couchbase_password=password
    fi
    echo $couchbase_password

    /opt/couchbase/bin/cbbackup -b cloudpass $server_url $dst_dir -u Administrator -p $couchbase_password

    if [ $? -eq 0 ]; then
        log "Backup couchbase is done successfully"
    else
        log "Backup couchbase fail"
    fi;

}

function backup_search()
{
    log "Backup search"
    # TODO
}

function backup_rest()
{
    log "Backup rest"
    # TODO
}

function backup_neo4j()
{
    log "Backup neo4j"
    # TODO
}

function backup_all()
{
    log "Backup all"
    #set -x

    # service ntp stop
    # ntpdate -s pool.ntp.org
    # service ntp start
    DATE=`date '+%Y-%m-%d-%H:%M:%S'`
    BACKUPDIR=/data/backup

    log "Backup Cloudpass" ### <--- logging timestamp is critical for performance tunning
    mk_dir $BACKUPDIR/nhidentity
    # TODO
    #cp -rp /cloudpass $BACKUPDIR/nhidentity/cloudpass.$DATE

    log "Stop search and rest service"
    service search stop
    service rest stop

    log "Wait for search service to stop"
    wait_service_stop "search"
    log "Wait for rest service to stop"
    wait_service_stop "rest"

    log "Backup search"
    mk_dir $BACKUPDIR/search

    log "tar /data/totvslabs"
    tar_dir /data/totvslabs $BACKUPDIR/search/totvslabs.tar.gz.$DATE

    log "Start search and rest services"
    service search start
    service rest start

    log "Confirm search service is up"
    [ "$(service_status search)" = "yes" ]
    service_status "search"

    log "Confirm rest service is up"
    [ "$(service_status search)" = "yes" ]
    service_status "rest"

    log "Backup up operation is done"
}

# Action performed
service_name=${1?}
couchbase_password=${1:-"password"}
case $service_name in
    "rest")
        backup_rest
        ;;
    "search")
        backup_search
        ;;
    "all")
        backup_all
        ;;
    "nagios")
        backup_nagios_rrd "/usr/local/nagiosgraph/var/rrd" "/home/backup/nagios_rrd"
        ;;
    "keystore")
        backup_keystore
        ;;
    "couchbase")
        backup_couchbase "$couchbase_password"
        ;;
    "neo4j")
        backup_neo4j
        ;;
    *)
        echo "ERROR: unsupported service_name($service_name) for backup"
esac

## File : nh_backup.sh ends
