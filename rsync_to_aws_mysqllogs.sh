#!/bin/bash

set -x 

export SRCDIR="/mysqllogs"
export DESTDIR="ubuntu@172.16.125.9:/mysqllogs"
export THREADS="8"
LOG=/tmp/sync_to_aws_mysqllogs.log
DATE=`date`
echo "Starting Time is $DATE " > $LOG
# RSYNC DIRECTORY STRUCTURE
cd $SRCDIR
   rsync -zr -f"+ */" -f"- *" -e "ssh -i /root/.ssh/dr-db.pem" $SRCDIR/ "$DESTDIR"/
   find . -type f | xargs -n1 -P$THREADS -I% rsync -azvt -e "ssh -i /root/.ssh/dr-db.pem" % "$DESTDIR"/%

 
DATE=`date`
echo "Ending Time is $DATE "  >> $LOG
