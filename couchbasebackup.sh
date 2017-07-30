#!/bin/bash -e
set -x

DATE=`date '+%Y-%m-%d-%H-%M'`
COUCHBASE_BACKUP_HOME=/data/backup/couchbase
ADMIN=Administrator
PASSWORD=password
CBBACKUP=/opt/couchbase/bin
TAR="/bin/tar -czvf"
RM="/bin/rm -rf"

MAILTO="bill.nguyen@totvs.com"

ipaddress=`/sbin/ifconfig eth0 | grep inet | awk '{print $2}' | cut -d: -f2`

if [ $# -eq 0 ]; then
    NODE=$ipaddress
else
    NODE=$ipaddress
fi

    echo "Daily Couchbase Backup "
    echo $NODE
if [ -d $COUCHBASE_BACKUP_HOME ]; then
    mkdir -p $COUCHBASE_BACKUP_HOME/cb-$NODE-$DATE
    $CBBACKUP/cbbackup http://$NODE:8091 -u $ADMIN -p $PASSWORD $COUCHBASE_BACKUP_HOME/cb-$NODE-$DATE 
    cd $COUCHBASE_BACKUP_HOME
    $TAR cb-$NODE-$DATE.tar.gz cb-$NODE-$DATE/
    $RM cb-$NODE-$DATE
    echo " Cleaning up now"
else
    mkdir -p $COUCHBASE_BACKUP_HOME/cb-$NODE-$DATE
    $CBBACKUP/cbbackup http://$NODE:8091 -u $ADMIN -p $PASSWORD $COUCHBASE_BACKUP_HOME/cb-$NODE-$DATE 
    echo " Cleaning up now"
fi

mailx -s "Daily Couchbase Backup: $NODE" $MAILTO < /dev/null

# else
# 
#     echo -e "\n\nUsage: $0 {Server IP }"
#     echo -e "ex: $0 172.20.18.13 \n\n"
# 
# fi
