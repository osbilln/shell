#!/bin/bash

set -x 
# SETUP OPTIONS
DATE=`date`
echo "Starting Time is $DATE " > /tmp/sync_to_aws.log 

   export SRCDIR="perfdb1:/data5"
   export DESTDIR="/data1"
   export THREADS="18"
 
   #rsync -zr -f"+ */" -f"- *" -e "ssh -i /root/.ssh/id_rsa" $SRCDIR "$DESTDIR"
   #find . -type f | xargs -n1 -P$THREADS -I% rsync -azvt -e "ssh -i /root/.ssh/id_rsa" % "$DESTDIR"/%
   rsync -zr -f"+ */" -f"- *" -e "ssh" $SRCDIR "$DESTDIR"
   find . -type f | xargs -n1 -P$THREADS -I% rsync -azvt -e "ssh" % "$DESTDIR"/%
 
   DATE=`date`
   echo "EndingTime is $DATE " > /tmp/sync_to_aws.log 


