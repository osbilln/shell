#!/bin/bash

export DATE=$(date +%F-%H-%M)
export LOGFILE=/tmp/compart_sync_$DATE.log
export BACKUP=/nfs2-data2/compart/backup


#  Compart backup

echo "Compart sync  [$$]  Started  at `date '+%Y-%m-%d %H:%M:%S'`" > $LOGFILE

su - naehas -c "rsync -Pav --exclude logs --delete $BACKUP/DocBridge_Delta-2.1.1.1 /export/data1/"

echo "Compart sync  [$$]  Completed  at `date '+%Y-%m-%d %H:%M:%S'`" >> $LOGFILE

