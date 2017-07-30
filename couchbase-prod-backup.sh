#!/bin/bash -e
set -x

DATE=`date '+%Y-%m-%d-%H-%M'`
COUCHBASE_BACKUP_HOME=/data/backup/couchbase
ADMIN=Administrator
PASSWORD=ZktwGaEhqbsAJHlAqiQP
CBBACKUP=/opt/couchbase/bin
NODE=172.21.16.12
#
#####
#
echo "Backing up couchbase every half hour "


if [ -d $COUCHBASE_BACKUP_HOME ]
  then
    mkdir -p $COUCHBASE_BACKUP_HOME/cb-$DATE
    $CBBACKUP/cbbackup http://$NODE:8091 -u $ADMIN -p $PASSWORD $COUCHBASE_BACKUP_HOME/cb-$DATE 
#     tar -cvfz $PASSWORD $COUCHBASE_BACKUP_HOME/cb-$DATE.tar.gz $COUCHBASE_BACKUP_HOME/cb-$DATE
    echo " Cleaning up now"
#     rm -rf $COUCHBASE_BACKUP_HOME/cb-$DATE
  else
   mkdir -p $COUCHBASE_BACKUP_HOME
    mkdir -p $COUCHBASE_BACKUP_HOME/cb-$DATE
    $CBBACKUP/cbbackup http://$NODE:8091 -u $ADMIN -p $PASSWORD $COUCHBASE_BACKUP_HOME/cb-$DATE 
#     tar -cvfz $PASSWORD $COUCHBASE_BACKUP_HOME/cb-$DATE.tar.gz $COUCHBASE_BACKUP_HOME/cb-$DATE
    echo " Cleaning up now"
#     rm -rf $COUCHBASE_BACKUP_HOME/cb-$DATE
fi

