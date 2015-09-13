#!/bin/bash

export DATE=$(date +%F-%H-%M)
export LOGFILE=/tmp/jira_confluence_hudson_$DATE.log
export BACKUP=/nfs2-data2/compart/backup


#  Compart backup

echo "Compart backup.  [$$]  Started  at `date '+%Y-%m-%d %H:%M:%S'`" > $LOGFILE

su - naehas -c "rsync -Pav $BACKUP/DocBridge_Delta-2.1.0.2 /export/data1/DocBridge_Delta-2.1.0.2/"

su - naehas -c "rsync -Pav $BACKUP/DocBridge_Delta-2.1.1.1 /export/data1/DocBridge_Delta-2.1.1.1/"

echo "Compart backup.  [$$]  Completed  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE

