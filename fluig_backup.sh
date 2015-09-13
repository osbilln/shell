#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_backup.sh $service_name
## Author : Denny <denny.zhang@totvs.com>, Bill <bill.nguyen@totvs.com>
## Description :
## --
## Created : <2014-07-30>
## Updated: Time-stamp: <2014-09-03 19:48:36>
##-------------------------------------------------------------------
# Backup critical data for fluig system:
#                  fluig_backup.sh nagios
#                  fluig_backup.sh neo4j
#                  fluig_backup.sh all
# 
############### Helper functions: TODO move to common library #################
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function mk_dir()
{
    local dir=${1?}
    if [ ! -e $dir ]; then
        mkdir -p $dir
    fi
}

function is_port_listening()
{
    local port=${1?}
    lsof -i tcp:$port | grep LISTEN 1>/dev/null
}

function service_status()
{
    local service_name=${1?}

    #TODO: later change to service $service_name status
    case $service_name in
        "search")
            is_port_listening 18085 && echo "yes"; exit 0
            ;;
        "rest")
            is_port_listening 18091 && echo "yes"; exit 0
            ;;
        *)
            echo "ERROR: unsupported service_name($service_name) for service_status"
    esac
    echo "no"
}

function wait_service_stop()
{
    local service_name=${1?}
    while [ "$(service_status "$service_name")" = "yes" ]; do
        # TODO add max seconds to wait
        sleep 1
    done;
}

function tar_dir()
{
    local dir=${1?}
    local tar_file=${2?}
    working_dir=`dirname $dir`
    cd $working_dir
    tar -zcf $tar_file `basename $dir`
}

function current_time()
{
    echo `date '+%Y-%m-%d-%H%M%S'`
}

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
    mk_dir $BACKUPDIR/fluigidentity
    # TODO
    #cp -rp /cloudpass $BACKUPDIR/fluigidentity/cloudpass.$DATE

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

## File : fluig_backup.sh ends
