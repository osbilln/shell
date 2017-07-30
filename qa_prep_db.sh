#!/bin/bash

if [ $# != 2 ]
then
  echo "Arg 1 must be an environment (staging, dev, preview, etc.....)"
  echo "Arg 2 must be a backup type (small, full)"
  exit
else
  ENV=$1
  echo "$ENV"
  BACKUP=$2
  echo "$BACKUP"
fi

WD_DIR=/home/qaprep
SSH_KEY=/home/qaprep/.ssh/id_rsa
SSH_USER=b248795
SSH_PORT=22
# SSH_HOST=50.56.109.50
SSH_HOST=hanjin.dreamhost.com
DB_USER=cpf_spt
DB_PASS=sunshine
LOG_FILE=qa_prep_db.log
DATE_START=`date "+%a %b %d %H:%M:%S"`
DAY=`date "+%u"`

#
#
DB_BACKUP_POST_REFRESH=backup_post_refresh.sql
if [ $ENV == "standalone" ]; then
   WIP_FILE=/home/spt/application/configs/database_changes.sql
   AFTER_BACKUP_SMALL=/home/spt/application/configs/run_after_backupsmall.sql
   DB_NAME=protools
else
   WIP_FILE=/home/spt/$ENV/application/configs/database_changes.sql
   AFTER_BACKUP_SMALL=/home/spt/$ENV/application/configs/run_after_backupsmall.sql
   DB_NAME=protools_$ENV
fi
#
if [ $BACKUP == "small" ]; then
  DB_FILE=backup$BACKUP.sql
else
  DB_FILE=backup.sql
fi


DB_BACKUP_POST_REFRESH=backup_post_refresh.sql

#
# Begin working...
#
echo "Beginning QA Prep (DB Only) - $DATE_START" | tee $WD_DIR/$LOG_FILE
echo "" | tee -a $WD_DIR/$LOG_FILE

# Grab latest copy of database from production
echo -n "Getting latest production dump from tools ... " | tee -a $WD_DIR/$LOG_FILE
scp $SSH_USER@$SSH_HOST:~/production/mysql/latest/$DB_FILE.gz $WD_DIR/$DB_FILE.gz
/bin/gunzip -q $WD_DIR/$DB_FILE.gz
echo "Done" | tee -a $WD_DIR/$LOG_FILE

# Restore database
echo -n "Restoring database now ... " | tee -a $WD_DIR/$LOG_FILE

mysql -u$DB_USER -p$DB_PASS -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE IF NOT EXISTS $DB_NAME";

mysql -u$DB_USER -p$DB_PASS $DB_NAME < $WD_DIR/$DB_FILE
echo "Done" | tee -a $WD_DIR/$LOG_FILE

# Add tables to small
if [ $BACKUP == "small" ]; then
echo -n "Adding tables to backupsmall... " | tee -a $WD_DIR/$LOG_FILE
mysql -u$DB_USER -p$DB_PASS $DB_NAME < $AFTER_BACKUP_SMALL
echo "Done" | tee -a $WD_DIR/$LOG_FILE
fi

# Upon completion, cleanup...
echo -n "Database restore complete. Removing working files ... " | tee -a $WD_DIR/$LOG_FILE
mv -f $WD_DIR/$DB_FILE $WD_DIR/$DB_FILE.$DAY | tee -a $WD_DIR/$LOG_FILE
echo "Done" | tee -a $WD_DIR/$LOG_FILE

# Reload any work in progress
echo -n "Loading work in progress SQL ... " | tee -a $WD_DIR/$LOG_FILE
mysql -u$DB_USER -p$DB_PASS $DB_NAME < $WIP_FILE
echo "Done" | tee -a $WD_DIR/$LOG_FILE

echo -n "Creating post refresh backup for loading into local systems" | tee -a $WD_DIR/$LOG_FILE
if [ $ENV == "dev" ]; then
cd $WD_DIR
/bin/rm $DB_BACKUP_POST_REFRESH.gz
mysqldump --opt -u$DB_USER -p$DB_PASS --ignore-table=protools_dev.cpf_debug_log --ignore-table=protools_dev.quoting_monthly_calcs --ignore-table=protools_dev.quoting_proposal_design_proposal_options $DB_NAME  > $DB_BACKUP_POST_REFRESH

echo -n "Appending commands to dump file for faster imports" | tee -a $WD_DIR/$LOG_FILE
echo "SET AUTOCOMMIT = 0; SET FOREIGN_KEY_CHECKS=0;">>$DB_BACKUP_POST_REFRESH

echo -n "Inserting commands at the beginning of dump file for faster imports" | tee -a $WD_DIR/$LOG_FILE
echo "SET AUTOCOMMIT = 0; SET FOREIGN_KEY_CHECKS=0;"|cat - $DB_BACKUP_POST_REFRESH > /tmp/out && mv /tmp/out $DB_BACKUP_POST_REFRESH 

gzip $DB_BACKUP_POST_REFRESH
fi

DATE_END=`date "+%a %b %d %H:%M:%S"`
echo ""  | tee -a $WD_DIR/$LOG_FILE
echo "Completed QA Prep (DB Only) - $DATE_END" | tee -a $WD_DIR/$LOG_FILE

