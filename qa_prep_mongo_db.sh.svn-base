#!/bin/bash
#
# This file grabs the latest version of the production mongo database
#
#

WD_DIR="/home/qaprep"
LOG_FILE="qa_prep_mongo_db.log"

SSH_KEY="/root/.ssh/id_dsa"
SSH_USER="root"
SSH_HOST="50.57.154.22"

DB_USER="cpf_spt"
DB_PASS="sunshine"
DATE_START=`date "+%a %b %d %H:%M:%S"`
DAY=`date "+%u"`

######## Do not modify below this point ########
MONGO_BACKUP_LOCATION="/data/backups/db/mongo/latest"
MONGO_BACKUP_FILENAME="mongo_backup.tar.bz2"
MONGO_DB_NAME="protools" 
DUMPDIRECTORYNAME="mongodump"

#
# Begin working...
#
echo "Beginning QA Prep (DB Only) - $DATE_START" | tee -a $WD_DIR/$LOG_FILE

# Grab latest copy of database from production
echo -n "Getting latest production dump from mongoprod ... " | tee -a $WD_DIR/$LOG_FILE

scp -i $SSH_KEY $SSH_USER@$SSH_HOST:$MONGO_BACKUP_LOCATION/$MONGO_BACKUP_FILENAME $WD_DIR/$MONGO_BACKUP_FILENAME

/bin/tar xjf $WD_DIR/$MONGO_BACKUP_FILENAME -C /tmp

echo "Done" | tee -a $WD_DIR/$LOG_FILE

# Restore mongo database
echo -n "Restoring mongo database now ... " | tee -a $WD_DIR/$LOG_FILE

mongorestore --db protools_preview --drop /tmp/$DUMPDIRECTORYNAME/$MONGO_DB_NAME
mongorestore --db protools_dev --drop /tmp/$DUMPDIRECTORYNAME/$MONGO_DB_NAME
mongorestore --db protools_staging --drop /tmp/$DUMPDIRECTORYNAME/$MONGO_DB_NAME

echo "Done" | tee -a $WD_DIR/$LOG_FILE

# Upon completion, cleanup...
echo -n "Database restore complete. Removing working files ... " | tee -a $WD_DIR/$LOG_FILE
rm -rf /tmp/$DUMPDIRECTORYNAME

echo "Done" | tee -a $WD_DIR/$LOG_FILE
echo "" | tee -a $WD_DIR/$LOG_FILE

exit 1
