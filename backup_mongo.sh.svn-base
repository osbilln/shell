#!/bin/bash
#
# This script runs on cpfmongoprod nightly cron (/usr/local/bin/backup_mongo.sh) to create a bz2 of the production protools mongo database
# and saves the dump locally as well as to DreamHost
#
# Create local variables and make needed directory
DAY=`date +%G%m%d`
HOUR=`date +%H`

# Name of mongo dataabse to backup
DATABASE_NAME="protools"

# BACKUP DIRECTORY
BACKUPDIR="/data/backups/db/mongo"

BACKUPFILENAME="mongo_backup.tar.bz2"


######## Do not modify below this point ########

DUMPDIRECTORYNAME="mongodump"

# Create required directories
if [ ! -e "$BACKUPDIR" ]		# Check Backup Directory exists.
	then
	mkdir -p "$BACKUPDIR"
fi

if [ ! -e "$BACKUPDIR/latest" ]		# Check Latest Directory exists.
	then
	mkdir -p "$BACKUPDIR/latest"
fi

# Change into our working directory
cd $BACKUPDIR

# Create required directories
if [ ! -e "$DAY/$HOUR" ]		# Check if directory exists.
	then
	mkdir -p "$DAY/$HOUR"
fi

# Remove backups older than X days
rm -fr `date +%G%m%d -d "14 days ago"`# Create backup with mongodump
date > $DAY/$HOUR/start.txt
NOW=`date "+%Y-%m-%d %H:%M:00"`

# Create a dump of mongo
mongodump -h 127.0.0.1:27017 -d $DATABASE_NAME --out $DUMPDIRECTORYNAME

# bz2 the dump folder (which contains the database along with all the individual collection files)
tar -cjf $DAY/$HOUR/$BACKUPFILENAME $DUMPDIRECTORYNAME

#  copy to latest dir
/bin/cp $DAY/$HOUR/$BACKUPFILENAME $BACKUPDIR/latest
 
# Clean up tasks...
rm -rf $DUMPDIRECTORYNAME

date > $DAY/$HOUR/end.txt

# Copy backup to Dreamhost via rsync
#  (our key here under ~/.ssh must be in authorized_keys at DH)
rsync -av -e ssh --compress --ignore-errors --perms --times --recursive $BACKUPDIR b248795@hanjin.dreamhost.com:production

