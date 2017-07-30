#!/bin/bash

if [ $# != 1 ]
then
  echo "Arg 1 must be an environment (staging, dev, preview, etc.....)"
  exit
else
  ENV=$1
  echo "$ENV"
fi

WD_DIR=/home/qaprep
SSH_KEY=/home/qaprep/.ssh/id_rsa
SSH_USER=qaprep
SSH_PORT=22
SSH_HOST=50.56.109.50
LOG_FILE=qa_prep_files.log
DATE_START=`date "+%a %b %d %H:%M:%S"`
DAY=`date "+%u"`
APP_PATH=/home/spt/$ENV

#
# Begin working...
#
echo "Beginning QA Prep Files - $DATE_START" | tee $WD_DIR/$LOG_FILE
echo "" | tee -a $WD_DIR/$LOG_FILE

# Grab latest copy of logos
echo -n "Getting latest logos tar from tools ... " | tee -a $WD_DIR/$LOG_FILE
cd $WD_DIR
/bin/rm -f ./logos.tar.gz
scp -i $SSH_KEY $SSH_USER@$SSH_HOST:/backups/files/latest/logos.tar.gz ./logos.tar.gz
cp ./logos.tar.gz $APP_PATH/public/logos/logos.tar.gz
cd $APP_PATH/public/logos
tar xvf ./logos.tar.gz
/bin/rm -f ./logos.tar.gz

# Grab latest copy of uploads
echo -n "Getting latest uploads tar from tools ... " | tee -a $WD_DIR/$LOG_FILE
cd $WD_DIR
/bin/rm -f ./uploads.tar.gz
scp -i $SSH_KEY $SSH_USER@$SSH_HOST:/backups/files/latest/uploads.tar.gz ./uploads.tar.gz
cp ./uploads.tar.gz $APP_PATH/public/uploads.tar.gz
cd $APP_PATH/public/uploads
tar xvf ./uploads.tar.gz
/bin/rm -f ./uploads.tar.gz

# Grab latest copy of templates
echo -n "Getting latest templates tar from tools ... " | tee -a $WD_DIR/$LOG_FILE
cd $WD_DIR
/bin/rm -f ./templates.tar.gz
scp -i $SSH_KEY $SSH_USER@$SSH_HOST:/backups/files/latest/templates.tar.gz ./templates.tar.gz
cp ./templates.tar.gz $APP_PATH/templates/templates.tar.gz
cd $APP_PATH/templates
tar xvf ./templates.tar.gz
/bin/rm -f ./templates.tar.gz

echo "Done" | tee -a $WD_DIR/$LOG_FILE

DATE_END=`date "+%a %b %d %H:%M:%S"`
echo ""  | tee -a $WD_DIR/$LOG_FILE
echo "Completed QA Prep Files - $DATE_END" | tee -a $WD_DIR/$LOG_FILE

