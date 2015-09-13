#!/bin/bash

set -x 
# SETUP OPTIONS
DATE=`date`
echo "Starting Time is $DATE " > /tmp/sync_to_aws.log 

   export SRCDIR="/data1/"
   export DESTDIR="ubuntu@172.16.125.9:/data2"
   export THREADS="10"
 
	cd $SRCDIR
   rsync -zr -f"+ */" -f"- *" -e "ssh -i /root/.ssh/dr-db.pem" $SRCDIR "$DESTDIR"
   find . -type f | xargs -n1 -P$THREADS -I% rsync -azvt -e "ssh -i /root/.ssh/dr-db.pem" % "$DESTDIR"/%
 
   DATE=`date`
   echo "EndingTime is $DATE " > /tmp/sync_to_aws.log 

