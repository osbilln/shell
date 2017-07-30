#!/bin/bash -e
set -x

DATE=`date '+%Y-%m-%d-%H-%M'`
COUCHBASE_BACKUP_HOME=/data/backup/couchbase
ADMIN=Administrator
PASSWORD=OyIcyM6djb02cWAaNOnr
CBBACKUP=/opt/couchbase/bin
# NODE=qa.fluigiden


if [ $# -eq 1 ]; then
    NODE=$1
echo "Backing up couchbase every day "


 if [ -d $COUCHBASE_BACKUP_HOME ]
  then
    mkdir -p $COUCHBASE_BACKUP_HOME/cb-$DATE
    $CBBACKUP/cbbackup http://$NODE:8091 -u $ADMIN -p $PASSWORD $COUCHBASE_BACKUP_HOME/$NODE-cb-$DATE 
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


else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
