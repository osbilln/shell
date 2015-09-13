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
function prodmergemaster()
{
    log "Backup prodmergemaster"
	src_dir=/export/data1/
	dst_dir=/data2/mergemaster
	rsync -azvt /export/data1/ db8:/data2/mergemaster
	email_check_status
}

function drmergemaster()
{
    log "Backup drmergemaster"
	src_dir=/data2/mergemaster/
	dst_dir=/data/mergemaster
	rsync -azvt $src_dir naehas@172.16.111.223:$dst_dir
	email_check_status
}


function compart()
{
    log "Backup compart-n"
	src_dir=/export/data1/
	dst_dir=/data2/compart
    # TODO
	rsync -azvt /export/data1/ db8:/data2/compart
	email_check_status
}

function drcompart()
{
    log "Backup drcompart-n"
	src_dir=/data2/compart/
	dst_dir=/data/compart
    # TODO
	rsync -azvt $src_dir naehas@172.16.111.223:$dst_dir
	email_check_status
}

function proddashboards()
{
    log "Backup proddashboards"
	src_dir=/usr/java/
	dst_dir=/data2/proddashboards
    # TODO
	rsync -azvt /export/data1/ db8:/data2/proddashboards
	email_check_status
}
function drdashboards()
{
    loghistory="/data2/logs/drdashboards.log"
    log "Backup drdashboards start" >> $loghistory
    src_dir="/data2/proddashboards/"
    dst_dir="/usr/java"
    rsync -azvt $srv_dir naehas@drweb2:$dst_dir
    log "Backup drdashboards completed" >> $loghistory
	email_check_status
}

function adapters()
{
    log "Backup adapters"
	src_dir=/export/data1/
	dst_dir=/data2/adapters
    # TODO
	rsync -azvt /export/data1/ db8:/data2/adapters
	email_check_status
}

function dradapters()
{ 
	service="$1"
    log "Backup adapters"
	src_dir=/data2/adapters/
	dst_dir=/data/adapters
    # TODO
	rsync -azvt $src_dir naehas@172.16.111.223:$dst_dir
        echo $service_name
 	email_check_status
}

function svn()
{
    log "Backup svn"
	src_dir=/etc
	dst_dir=/data2/svn
    # TODO
	rsync -PrltDvO /etc db8:/data2/svn
	email_check_status
}

function drsvn()
{
    log "Backup drsvn"
	src_dir=/data2/svn/
	dst_dir=/data/svn
    # TODO
	rsync -PrltDvO $src_dir naehas@172.16.111.223:$dst_dir
	email_check_status
}


function build()
{
    log "Backup build"
	src_dir=/backup/hudson/.hudson
	dst_dir=/data2/build
    # TODO
	rsync -avzt --exclude builds --exclude logs --exclude jobs_backup $src_dir db8:$dst_dir
	email_check_status
}

function drbuild()
{
    log "Backup drbuild"
	src_dir="/data2/build/.hudson/"
	dst_dir="/data/hudson"
    # TODO
	rsync -avzt --exclude builds --exclude logs --exclude jobs_backup $src_dir naehas@172.16.126.63:$dst_dir
	email_check_status
}

function jira()
{
    log "Backup jira"
	src_dir=/home/naehas/jira_424-data/
	dst_dir=/data2/jira
    # TODO
	rsync -azvt /home/naehas/jira_424-data/ db8:$dst_dir/data
	rsync -azvt /export/data2/java/atlassian-jira-4.3.4-standalone/ db8:$dst_dir/installation/
	email_check_status
}

function drjira()
{
    log "Backup drjira"
	src_dir="/data2/jira/"
	dst_dir="/data/jira"
    # TODO
	rsync -azvt $src_dir naehas@172.16.126.63:$dst_dir
	email_check_status
}

function confluence()
{
    log "Backup confluence"
	src_dir=/data2/confluence/
	dst_dir=/data/confluence
    # TODO
	rsync -azvt /home/naehas/confluence-data/ $dst_dir/data
	email_check_status
	rsync -azvt /export/data2/java/confluence-3.5.7-std/ $dst_dir/installation
	email_check_status
}

function drconfluence()
{
    log "Backup drConfluence"
	src_dir=/data2/confluence/
	dst_dir=/data/confluence
    # TODO
	rsync -azvt $src_dir naehas@172.16.126.63:$dst_dir
	email_check_status
}

function email_check_status()
{
        echo "From email function - $service_name"
	if [ $? -eq 0 ]; then
        	mail -s "Backup $service_name status - SUCCESSFUL" billn@naehas.com < /dev/null
        elif [ $? -eq 1 ]; then
        	mail -s "Backup $service_name status - FAILED" billn@naehas.com < /dev/null
        fi;
}
function drall()
{
	mail_check_status
        exit 1
}
# Action performed
service_name=${1?}
case $service_name in
    "compart")
        compart
        ;;
    "drcompart")
        drcompart
        ;;
    "prodmergemaster")
        prodmergemaster
        ;;
    "drmergemaster")
        drmergemaster
        ;;
    "proddashboards")
        proddashboards
        ;;
    "drdashboards")
        drdashboards
        ;;
    "adapters")
        adapters
        ;;
    "dradapters")
        dradapters
        ;;
    "svn")
        svn
        ;;
    "drsvn")
        drsvn
        ;;
    "build")
        build
        ;;
    "drbuild")
        drbuild
        ;;
    "jira")
        jira
        ;;
    "drjira")
        drjira
        ;;
    "confluence")
        confluence
        ;;
    "drconfluence")
        drconfluence
        ;;
    "drall")
        drdashboards
        dradapters
        drcompart
        drmergemaster
        drsvn
        drbuild
        drjira
        drconfluence
        ;;
    *)
        echo "ERROR: unsupported service_name($service_name) for backup"
esac

### File : nh_backup.sh ends
