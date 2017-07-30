#!/bin/bash

set -x 
# SETUP OPTIONS
DATE=`date`
echo "Starting Time is $DATE " > /tmp/sync_to_aws.log 

   export SRCDIR="/data5"
   export DESTDIR="perfdbi1:/data1"
   export THREADS="10"
   cd $SRCDIR 
   rsync -zr -f"+ */" -f"- *" -e "ssh -i /root/.ssh/id_rsa" $SRCDIR "$DESTDIR"
   find . -type f | xargs -n1 -P$THREADS -I% rsync -azvt -e "ssh -i /root/.ssh/id_rsa" % "$DESTDIR"/%
 
   DATE=`date`
   echo "EndingTime is $DATE " > /tmp/sync_to_aws.log 



