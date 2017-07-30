#!/bin/bash -e
##-------------------------------------------------------------------
## File : backup.sh $service_name
## Author : Bill <bill@zuberance.com>
## Description :
## --
## Created : <2014-07-30>
## Updated: Time-stamp: <2016-01-15 09:20:08>
##-------------------------------------------------------------------
# Backup critical data for nh system:
#                  backup wom_apps_prod, redirect_prod, report_prod
#                  
#                  
. /shared/util/backup/utility.sh

####################################################################
DATE=`date '+%Y-%m-%d-%H%M'`
SERVERNAME="10.100.109.32"

function backup_nagios_rrd()
{
    src_dir=${1:-"/usr/local/nagiosgraph/var/rrd"}
    dest_dir=${2:-"/home/backup/nagios_rrd"}
    log "Backup nagios rrd: from $src_dir to $dest_dir"

    mk_dir $dest_dir
    tar_dir $src_dir $dest_dir/$(current_time).tar.gz
}


function rsync_net ()
{
    LOG="/tmp/backup.log"
    rsyncnet_connect='8456@usw-s008.rsync.net'
    rsyncnet_base_dst=${rsyncnet_connect}:
    rsync_command='/usr/bin/rsync'
    eval `ssh-agent`
    ssh-add ~eng/.ssh/rsync.net
}

function rsync_wom_apps_prod_to_aws ()
{
    LOG="/tmp/backup.log"
    echo "Starting backup to aws" 
    echo -e "\n\n" 
    src_dir=$2
    dst_dir=$3
    echo "starting database backups to AWS : WOM_APPS_PROD, REDIRECT_PROD, REPORT_PROD "
    rsync -azvtbu $src_dir $dst_dir
    email
}

function dr_rsync_net ()
{
    rsync_net
    echo "Starting backup to $rsyncnet_base_dst" 
    echo -e "\n\n" 
    ssh ${rsyncnet_connect} 'touch backup_start'
    src_dir="/shared/db_backup/latest"
    echo "starting database backups to rsync.net: WOM_APPS_PROD, REDIRECT_PROD, REPORT_PROD "
    ${rsync_command} -vaz $src_dir/ ${rsyncnet_base_dst}db_backup/
    echo -e "\n\n" 
        #record the completion time
    echo -e "\n\n" 
    ssh ${rsyncnet_connect} 'touch backup_end' 
    echo "Backup completed" 
    cd $src_dir
    mv *.gz ../archive/
    email
}

function dr_shared()
{
    echo -e "\n\n" 
    echo "starting backup - binary core storage /shared" >> ${LOG}
    ${rsync_command} -vaz /shared/binary ${rsyncnet_base_dst}binary

}
function backup_shared()
{
    cd /shared
    tar zcvf binary.tar.gz binary/

}
function import_pguser()
{
    export PGUSER="eng"
    export PGPASSWORD="62894070" 
}

function export_pguser()
{
    export PGUSER=" "
    export PGPASSWORD=" " 
}

function action_table()
{
    servername="$SERVERNAME"
    instance_name=wom_apps_prod 
    include_list="-t action"
    dst="/shared/db_backup/latest"
    import_pguser
    pg_dump -h $servername $include_list -v $instance_name > $dst/action.sql
    export_pguser
    gzip $dst/action.sql
    export_pguser
}
function impression_table()
{
    servername="$SERVERNAME"
    instance_name=wom_apps_prod 
    include_list="-t impression"
    dst="/shared/db_backup/latest"
    import_pguser
    pg_dump -h $servername $include_list -v $instance_name > $dst/impression.sql
    export_pguser
    gzip $dst/impression.sql
    export_pguser
}
function conversion_table()
{
    servername="$SERVERNAME"
    instance_name=wom_apps_prod 
    include_list="-t conversion"
    dst="/shared/db_backup/latest"
    import_pguser
    pg_dump -h $servername $include_list -v $instance_name > $dst/conversion.sql
    export_pguser
    gzip $dst/conversion.sql
    export_pguser
}
function wom_apps_prod_include()
{
    email
    servername="$SERVERNAME"
    instance_name=wom_apps_prod 
    exclude_list="-t action_* -t conversion_* -t impression_*"
    import_pguser
    pg_dump -v -h $servername -Fc $exclude_list $instance_name > /home/eng/wom_apps_prod_include.dump
    export_pguser
    email
}
function wom_apps_prod_exclude()
{
    email
    servername="$SERVERNAME"
    instance_name=wom_apps_prod 
    exclude_list="-T action_20* -T impression_20*  -T conversion_20*"
    import_pguser
    pg_dump -v -h $servername -Fc $exclude_list $instance_name > /home/eng/wom_apps_prod_exclude.dump
    export_pguser
    email
}
function wom_apps_prod()
{
    servername="$SERVERNAME"
    instance_name=wom_apps_prod 
    exclude_list="-t action_* -t conversion_* -t impression_*"
    #exclude_list="-T action_20* -T impression_20*  -T conversion_20*"
    tmp_dst_file="/home/eng/wom_apps_prod.sql.$DATE"
    dst="/shared/db_backup/latest"
    import_pguser
    # pg_dump -v -h $servername $exclude_list $instance_name > $tmp_dst_file
    # pg_dump -v -h $servername $instance_name > $tmp_dst_file
    pg_dump -v -h $servername -Fc $exclude_list $instance_name > /home/eng/wom_apps_prod.dump
    export_pguser
    gzip $tmp_dst_file
    mv $tmp_dst_file.gz $dst/
    export_pguser
    email
}

function redirect_prod()
{
    email
    servername="10.100.109.24"
    instance_name="redirect_prod"
    exclude_list=""
    tmp_dst_file="/home/eng/redirect_prod.sql.$DATE"
    dst="/shared/db_backup/latest"
    import_pguser
    #pg_dump -h "$servername" -c redirect_prod  > "$tmp_dst_file"
    pg_dump -h "$servername" -U eng redirect_prod  -Fc > ~/redirect_prod.dump
    export_pguser
    email
}

function report_prod()
{
    email
    servername="10.100.109.22"
    instance_name="report_prod"
    exclude_list=""
    tmp_dst_file="/home/eng/report_prod.sql.$DATE"
    dst="/shared/db_backup/latest"
    import_pguser
    #pg_dump -h $servername -c $instance_name  > $tmp_dst_file
    pg_dump -h $servername -U eng report_prod  -Fc > report_prod.dump
    email
}

function tracking_prod()
{
    email
    servername="10.100.109.23"
    instance_name="tracking_prod"
    import_pguser
    pg_dump -h $servername -U eng tracking_prod  -Fc > tracking_prod.dump
    email
}
function email()
{
        echo "From email function - $service_name"
	if [ $? -eq 0 ]; then
        	mail -s "Backup $service_name status - SUCCESSFUL" bill@zuberance.com < /dev/null
        elif [ $? -eq 1 ]; then
        	mail -s "Backup $service_name status - FAILED" bill@zuberance.com < /dev/null
        fi;
}

function cleanup()
{
	tmp_dst_file="/home/eng"
	rm -rf $tmp_dst_file/*sql*
        exit 1
}

function drall()
{
	mail_check_status
        exit 1
}

# Action performed
service_name=${1?}
case $service_name in    
    "wom_apps_prod_include")
        wom_apps_prod_include
        ;;
    "wom_apps_prod_exclude")
        wom_apps_prod_exclude
        ;;
    "wom_apps_prod")
        wom_apps_prod
        ;;
    "redirect_prod")
        redirect_prod
        ;;
    "report_prod")
        report_prod
        ;;
    "tracking_prod")
        tracking_prod
        ;;
    "dr_rsync_net")
        dr_rsync_net
        ;;
    "rsync_wom_apps_prod_to_aws")
        rsync_wom_apps_prod_to_aws $1 $2
        ;;
    "dr_rsync_aws")
        dr_rsync_aws
        ;;
    "action")
        action_table
        ;;
    "cleanup")
        cleanup
        ;;
    "backupall")
        redirect_prod
        report_prod
        wom_apps_prod
	dr_rsync_aws
        dr_rsync_net
 	cleanup
        ;;
    *)
        echo "ERROR: unsupported service_name($service_name) for backup"
esac

### File : nh_backup.sh ends
