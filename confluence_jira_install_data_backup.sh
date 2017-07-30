#!/bin/bash

export DATE=$(date +%F-%H-%M)
export LOGFILE=/tmp/jira_confluence_$DATE.log
export BACKUP=/nfs2-data2/dev/backup


#  Confluence backup

echo "Confluence backup.  [$$]  Started  at `date '+%Y-%m-%d %H:%M:%S'`" > $LOGFILE

su - naehas -c "rsync -Pav /home/naehas/confluence-data $BACKUP/confluence/"

su - naehas -c "rsync -Pav /usr/java/confluence-3.5.7-std $BACKUP/confluence-installation/"

echo "Confluence backup.  [$$]  Completed  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE


# Jira backup

echo "Jira backup.  [$$]  Started  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE

su - naehas -c "rsync -Pav /home/naehas/jira_424-data $BACKUP/jira/"

su - naehas -c "rsync -Pav /usr/java/atlassian-jira-4.3.4-standalone $BACKUP/jira-installation/"

echo "Jira backup.  [$$]  Completed  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE
