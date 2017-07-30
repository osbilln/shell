#!/bin/bash

export DATE=$(date +%F-%H-%M)
export LOGFILE=/tmp/jira_confluence_db_and_hudson_$DATE.log
export BACKUP=/nfs2-data2/dev/backup
#export BACKUP=/nfs1/dev/backup
#export BACKUP=/mnt2/backup


#  Confluence backup
echo "Confluence DB backup.  [$$]  Started  at `date '+%Y-%m-%d %H:%M:%S'`" > $LOGFILE

mysqldump confluencedb > $BACKUP/confluence/${DATE}_confluence_db.sql

echo "Confluence DB backup.  [$$]  Completed  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE


# Jira backup
echo "Jira DB backup.  [$$]  Started  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE

mysqldump jiradb_434 > $BACKUP/jira/${DATE}_jira_db_434.sql

echo "Jira DB backup.  [$$]  Completed  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE


# Hudson Backup
echo "Hudson backup.  [$$]  Started  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE

su - naehas -c "rsync -Pav --exclude builds --exclude logs --exclude jobs_backup /mnt2/hudson/.hudson $BACKUP/hudson/"
#su - naehas -c "rsync -Pav --exclude builds --exclude logs --exclude jobs --exclude jobs_backup /mnt2/hudson/.hudson $BACKUP/hudson/"
#su - naehas -c "rsync -Pav --delete /mnt2/hudson/.hudson/jobs $BACKUP/hudson/.hudson/"
#su - naehas -c "rsync -Pav /mnt2/hudson/.hudson/jobs $BACKUP/hudson/.hudson/"

echo "Hudson backup.  [$$]  Completed  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE

# Cleanup SQL files
find $BACKUP/jira/ -name "*_jira_db_434.sql" -mtime +30 -exec rm -f {} \;
find $BACKUP/confluence/ -name "*_confluence_db.sql" -mtime +30 -exec rm -f {} \;
