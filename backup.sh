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
<<<<<<< HEAD
<<<<<<< HEAD
# 
set -x
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
#                  nh_backup.sh nagios
#                  nh_backup.sh neo4j
#                  nh_backup.sh all
# 
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
. /usr/lib/nh_devops_lib.sh

####################################################################
function prodmergemaster()
{
    log "Backup prodmergemaster"
	src_dir=/export/data1/
	dst_dir=/data2/mergemaster
<<<<<<< HEAD
<<<<<<< HEAD
    loginaccount
	rsync -azvt naehas@prodmergemaster4.naehas.com:/export/data1/ /data2/mergemaster
=======
	rsync -azvt /export/data1/ db8:/data2/mergemaster
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
	rsync -azvt /export/data1/ db8:/data2/mergemaster
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}

function drmergemaster()
{
    log "Backup drmergemaster"
<<<<<<< HEAD
<<<<<<< HEAD
	src_dir=/data2/mergemaster
	dst_dir=/data/mergemaster
    loginaccount
	rsync -azvt $src_dir/ naehas@drbuild1.naehas.com:$dst_dir
	email_check_status
}

function prodcompart()
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	src_dir=/data2/mergemaster/
	dst_dir=/data/mergemaster
	rsync -azvt $src_dir naehas@172.16.111.223:$dst_dir
	email_check_status
}


function compart()
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
{
    log "Backup compart-n"
	src_dir=/export/data1/
	dst_dir=/data2/compart
    # TODO
<<<<<<< HEAD
<<<<<<< HEAD
    loginaccount
	rsync -azvt naehas@compart-n.naehas.com:$src_dir/ $dst_dir
=======
	rsync -azvt /export/data1/ db8:/data2/compart
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
	rsync -azvt /export/data1/ db8:/data2/compart
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}

function drcompart()
{
    log "Backup drcompart-n"
<<<<<<< HEAD
<<<<<<< HEAD
	src_dir=/data2/compart
	dst_dir=/data/compart
    # TODO
    loginaccount
	rsync -azvt $src_dir/ naehas@drbuild1.naehas.com:$dst_dir
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	src_dir=/data2/compart/
	dst_dir=/data/compart
    # TODO
	rsync -azvt $src_dir naehas@172.16.111.223:$dst_dir
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}

function proddashboards()
{
    log "Backup proddashboards"
<<<<<<< HEAD
<<<<<<< HEAD
	src_dir=/usr/java
	dst_dir=/data2/proddashboards
    exclude="--exclude logs"
    # TODO
    loginaccount
#	rsync -azvt naehas@web3.naehas.com:$src_dir/ /data2/proddashboards
	/usr/bin/rsync --progress -avSHPrt --delete naehas@prodwebe1.naehas.com:$src_dir/ /data2/proddashboards
	/usr/bin/rsync --progress -avSHPrt --delete naehas@prodwebf1.naehas.com:$src_dir/ /data2/proddashboards
	/usr/bin/rsync --progress -avSHPrt --delete naehas@prodwebg1.naehas.com:$src_dir/ /data2/proddashboards
	/usr/bin/rsync --progress -avSHPrt --delete naehas@prodwebh1.naehas.com:$src_dir/ /data2/proddashboards
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	src_dir=/usr/java/
	dst_dir=/data2/proddashboards
    # TODO
	rsync -azvt /export/data1/ db8:/data2/proddashboards
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}
function drdashboards()
{
    loghistory="/data2/logs/drdashboards.log"
    log "Backup drdashboards start" >> $loghistory
<<<<<<< HEAD
<<<<<<< HEAD
    src_dir="/data2/proddashboards"
    dst_dir="/usr/java"
    loginaccount
    rsync -azvt $src_dir/ naehas@drweb1.naehas.com:$dst_dir
=======
    src_dir="/data2/proddashboards/"
    dst_dir="/usr/java"
    rsync -azvt $srv_dir naehas@drweb2:$dst_dir
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
    src_dir="/data2/proddashboards/"
    dst_dir="/usr/java"
    rsync -azvt $srv_dir naehas@drweb2:$dst_dir
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
    log "Backup drdashboards completed" >> $loghistory
	email_check_status
}

<<<<<<< HEAD
<<<<<<< HEAD
function prodhaproxy()
{
    log "Backup prodhaproxy"
	src_dir=/etc/haproxy
	dst_dir=/data2/haproxy
    exclude="--exclude logs"
    loginaccount
	/usr/bin/rsync --progress -avSHPrt --delete naehas@prodlbf1.naehas.com:$src_dir/ $dst_dir
	email_check_status
}
function prodstatic()
{
    log "Backup prodstatic"
	src_dir=/var/www/html
	dst_dir=/data2/html
    exclude="--exclude logs"
    loginaccount
	/usr/bin/rsync --progress -avSHPrt --delete naehas@prodlbf1.naehas.com:$src_dir/ $dst_dir
	email_check_status
}
function prodha()
{
    log "Backup prodha"
	src_dir=/etc/ha.d
	dst_dir=/data2/ha
    exclude="--exclude logs"
    loginaccount
	/usr/bin/rsync --progress -avSHPrt --delete naehas@prodlbf1.naehas.com:$src_dir/ $dst_dir
	email_check_status
}
function drhaproxy()
{
    loghistory="/data2/logs/drhaproxy.log"
    log "Backup drdashboards starts" >> $loghistory
    src_dir="/data2/haproxy"
    dst_dir="/etc/haproxy"
    scp -r -i /home/ubuntu/.ssh/id_rsa $src_dir/ ubuntu@drhaproxy1.naehas.com:$dst_dir
    log "Backup drhaproxy completed" >> $loghistory
	email_check_status
}
function drstatic()
{
    loghistory="/data2/logs/drstatic.log"
    log "Backup drdashboards starts" >> $loghistory
    src_dir=/data2/html
    dst_dir=/var/www/html
    loginaccount
    /usr/bin/rsync --progress -avSHPrt --delete $src_dir/ naehas@drhaproxy1.naehas.com:$dst_dir
    log "Backup drstatic completed" >> $loghistory
	email_check_status
}
function drha()
{
    loghistory="/data2/logs/drha.log"
    log "Backup drdashboards starts" >> $loghistory
    src_dir=/data2/ha
    dst_dir=/etc/ha.d
    scp -r -i /home/ubuntu/.ssh/id_rsa $src_dir/ ubuntu@drhaproxy1.naehas.com:$dst_dir
    log "Backup drha completed" >> $loghistory
	email_check_status
}

function prodnaehas()
{
    log "Backup proddashboards"
    src_dir=/home/naehas
    dst_dir=/data2/prodnaehas
    # TODO
    loginaccount
    rsync -azvt naehas@web3.naehas.com:$src_dir/ /data2/prodnaehas
    email_check_status
}
function drnaehas()
{
    loghistory="/data2/logs/drdashboards.log"
    log "Backup drdashboards start" >> $loghistory
    src_dir="/data2/prodnaehas"
    dst_dir="/home/naehas"
    loginaccount
    rsync -azvt $src_dir/ naehas@drweb1.naehas.com:
    log "Backup drdashboards completed" >> $loghistory
    email_check_status
}

function prodadapters()
{
    log "Backup adapters"
	src_dir=/usr/java
	dst_dir=/data2/prodadapters
    # TODO
    loginaccount
	rsync -azvt naehas@prodintg1:/usr/java/ /data2/prodadapters
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
function adapters()
{
    log "Backup adapters"
	src_dir=/export/data1/
	dst_dir=/data2/adapters
    # TODO
	rsync -azvt /export/data1/ db8:/data2/adapters
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}

function dradapters()
{ 
	service="$1"
    log "Backup adapters"
<<<<<<< HEAD
<<<<<<< HEAD
	src_dir=/data2/prodadapters
	dst_dir=/data/adapters
    # TODO
    loginaccount
	rsync -azvt $src_dir/ naehas@drbuild1.naehas.com:$dst_dir
    echo $service_name
 	email_check_status
}

function prodsvn()
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	src_dir=/data2/adapters/
	dst_dir=/data/adapters
    # TODO
	rsync -azvt $src_dir naehas@172.16.111.223:$dst_dir
        echo $service_name
 	email_check_status
}

function svn()
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
{
    log "Backup svn"
	src_dir=/etc
	dst_dir=/data2/svn
    # TODO
<<<<<<< HEAD
<<<<<<< HEAD
    loginaccount
	rsync -PrltDvO root@svn.naehas.com:$src_dir/ $dst_dir
=======
	rsync -PrltDvO /etc db8:/data2/svn
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
	rsync -PrltDvO /etc db8:/data2/svn
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}

function drsvn()
{
    log "Backup drsvn"
<<<<<<< HEAD
<<<<<<< HEAD
	src_dir=/data2/svn
	dst_dir=/data/svn
    # TODO
    loginaccount
	rsync -PrltDvO $src_dir/ naehas@drbuild1.naehas.com:$dst_dir
	email_check_status
}

function prodbuild()
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	src_dir=/data2/svn/
	dst_dir=/data/svn
    # TODO
	rsync -PrltDvO $src_dir naehas@172.16.111.223:$dst_dir
	email_check_status
}


function build()
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
{
    log "Backup build"
	src_dir=/backup/hudson/.hudson
	dst_dir=/data2/build
    # TODO
<<<<<<< HEAD
<<<<<<< HEAD
    loginaccount
	rsync -avzt --exclude builds --exclude logs --exclude jobs_backup naehas@dev.naehas.com:$src_dir $dst_dir
=======
	rsync -avzt --exclude builds --exclude logs --exclude jobs_backup $src_dir db8:$dst_dir
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
	rsync -avzt --exclude builds --exclude logs --exclude jobs_backup $src_dir db8:$dst_dir
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}

function drbuild()
{
    log "Backup drbuild"
	src_dir="/data2/build/.hudson/"
	dst_dir="/data/hudson"
    # TODO
<<<<<<< HEAD
<<<<<<< HEAD
    loginaccount
	rsync -avzt --exclude builds --exclude logs --exclude jobs_backup $src_dir naehas@drbuild1.naehas.com:$dst_dir
	email_check_status
}

function prodjira()
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	rsync -avzt --exclude builds --exclude logs --exclude jobs_backup $src_dir naehas@172.16.126.63:$dst_dir
	email_check_status
}

function jira()
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
{
    log "Backup jira"
	src_dir=/home/naehas/jira_424-data/
	dst_dir=/data2/jira
    # TODO
<<<<<<< HEAD
<<<<<<< HEAD
    loginaccount
	rsync -azvt naehas@jira-confluence.naehas.com:/home/naehas/jira_424-data/ $dst_dir/data
	rsync -azvt naehas@jira-confluence.naehas.com:/export/data2/java/atlassian-jira-4.3.4-standalone/ $dst_dir/installation/
=======
	rsync -azvt /home/naehas/jira_424-data/ db8:$dst_dir/data
	rsync -azvt /export/data2/java/atlassian-jira-4.3.4-standalone/ db8:$dst_dir/installation/
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
	rsync -azvt /home/naehas/jira_424-data/ db8:$dst_dir/data
	rsync -azvt /export/data2/java/atlassian-jira-4.3.4-standalone/ db8:$dst_dir/installation/
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}

function drjira()
{
    log "Backup drjira"
<<<<<<< HEAD
<<<<<<< HEAD
	src_dir="/data2/jira"
	dst_dir="/data/jira"
    # TODO
    loginaccount
	rsync -azvt $src_dir/ naehas@drbuild1.naehas.com:$dst_dir
	email_check_status
}

function prodconfluence()
{
    log "Backup confluence"
	src_dir=/home/naehas/confluence-data
	dst_dir=/data2/confluence
    # TODO
    loginaccount
	rsync -azvt naehas@jira-confluence.naehas.com:$src_dir/ $dst_dir/data
	email_check_status
	#rsync -azvt /export/data2/java/confluence-3.5.7-std/ $dst_dir/installation
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
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
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	email_check_status
}

function drconfluence()
{
    log "Backup drConfluence"
<<<<<<< HEAD
<<<<<<< HEAD
	src_dir=/data2/confluence
	dst_dir=/data/confluence
    # TODO
    loginaccount
	rsync -azvt $src_dir/ naehas@drbuild1.naehas.com:$dst_dir
	email_check_status
}
function prodmergedb()
{
    log "Backup prodmergedb"
    src_dir=/data/backup
    dst_dir=/data2/mergedb
    backupmergedb="mysqldump -unaehas -p1234rty7890 --all-databases |gzip -9 > /data/backup/prodmergedb3-all-databases_`date +%F-%H-%M`.sql.gz"
    # TODO
    loginaccount
    #ssh root@prodmergedb3.naehas.com -C "$backupmergedb"
    rsync -azvt root@prodmergedb3.naehas.com:$src_dir/ $dst_dir
    ssh root@prodmergedb3.naehas.com -C "rm -rf $src_dir/*"
    email_check_status
    #rsync -azvt /export/data2/java/confluence-3.5.7-std/ $dst_dir/installation
    email_check_status
}

function drmergedb()
{
    log "Backup drmergedb"
    src_dir=/data2/mergedb
    dst_dir=/root/backup
    # TODO
    loginaccount
    rsync -azvt $src_dir/ root@drdb4.naehas.com:$dst_dir/
    email_check_status
}

function loginaccount
{
    cd 
    eval `ssh-agent`
    ssh-add ~/.au/id_rsa
}
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
	src_dir=/data2/confluence/
	dst_dir=/data/confluence
    # TODO
	rsync -azvt $src_dir naehas@172.16.126.63:$dst_dir
	email_check_status
}
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3

function email_check_status()
{
        echo "From email function - $service_name"
	if [ $? -eq 0 ]; then
        	mail -s "Backup $service_name status - SUCCESSFUL" billn@naehas.com < /dev/null
        elif [ $? -eq 1 ]; then
        	mail -s "Backup $service_name status - FAILED" billn@naehas.com < /dev/null
        fi;
}
<<<<<<< HEAD
<<<<<<< HEAD

function perfweb2dashboards()
{
    log "Backup perfweb2dashboards"
	src_dir=/usr/java
	dst_dir=/data7/perfweb2
    # TODO
    loginaccount
	rsync -azvt naehas@perfweb2.naehas.com:$src_dir/ $dst_dir
	email_check_status
}

function perfweb1dashboards()
{
    log "Backup perfweb1dashboards"
	src_dir=/usr/java
	dst_dir=/data7/perfweb1
    # TODO
    loginaccount
	rsync -azvt naehas@perfweb1.naehas.com:$src_dir/ $dst_dir
	email_check_status
}
function drall()
{
    drcompart
    drdashboards
    drmergemaster
    drjira
    drsvn
    drconfluence
    dradapters
    drdashboards
    drmergedb
    drstatic
    mail_check_status
        exit 1
}
function prodall()
{
    prodcompart
    prodmergemaster
    proddashboards
    prodnaehas
    prodadapters
    prodsvn
    prodjira
    prodconfluence
    prodmergedb
    prodstatic
    mail_check_status
=======
function drall()
{
	mail_check_status
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
function drall()
{
	mail_check_status
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
        exit 1
}
# Action performed
service_name=${1?}
case $service_name in
<<<<<<< HEAD
<<<<<<< HEAD
    "prodcompart")
        prodcompart
=======
    "compart")
        compart
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
    "compart")
        compart
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
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
<<<<<<< HEAD
<<<<<<< HEAD
    "prodnaehas")
        prodnaehas
        ;;
    "drnaehas")
        drnaehas
        ;;
    "prodadapters")
        prodadapters
=======
    "adapters")
        adapters
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
    "adapters")
        adapters
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
        ;;
    "dradapters")
        dradapters
        ;;
<<<<<<< HEAD
<<<<<<< HEAD
    "prodsvn")
        prodsvn
=======
    "svn")
        svn
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
    "svn")
        svn
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
        ;;
    "drsvn")
        drsvn
        ;;
<<<<<<< HEAD
<<<<<<< HEAD
    "prodbuild")
        prodbuild
=======
    "build")
        build
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
    "build")
        build
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
        ;;
    "drbuild")
        drbuild
        ;;
<<<<<<< HEAD
<<<<<<< HEAD
    "prodjira")
        prodjira
=======
    "jira")
        jira
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
    "jira")
        jira
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
        ;;
    "drjira")
        drjira
        ;;
<<<<<<< HEAD
<<<<<<< HEAD
    "prodconfluence")
        prodconfluence
=======
    "confluence")
        confluence
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
    "confluence")
        confluence
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
        ;;
    "drconfluence")
        drconfluence
        ;;
<<<<<<< HEAD
<<<<<<< HEAD
    "prodmergedb")
        prodmergedb
        ;;
    "drmergedb")
        drmergedb
        ;;
    "prodhaproxy")
        prodhaproxy
        ;;
    "prodstatic")
        prodstatic
        ;;
    "prodha")
        prodha
        ;;
    "drhaproxy")
        drhaproxy
        ;;
    "drstatic")
        drstatic
        ;;
    "drha")
        drha
        ;;
    "perfweb1dashboards")
        perfweb1dashboards
        ;;
    "perfweb2dashboards")
        perfweb2dashboards
        ;;
    "all")
        prodall
        drall
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
    "drall")
        drdashboards
        dradapters
        drcompart
        drmergemaster
        drsvn
        drbuild
        drjira
        drconfluence
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
        ;;
    *)
        echo "ERROR: unsupported service_name($service_name) for backup"
esac

### File : nh_backup.sh ends
