#!/bin/bash
set -x 
# SETUP OPTIONS
if [ "$#" -ne 2 ]; then
    echo "usage: usrjav_backup.sh <SOURCE> <DESTINATION>"
    echo "example: usrjav_backup.sh naehas@perfweb1:/usr/java /data7/perfweb1"
    exit
fi


DATE=`date`
echo "Starting Time is $DATE " > /tmp/sync_to_aws.log 

   export SRCDIR="${1}"
   export DESTDIR="${2}"
   export THREADS="5"
 
	cd $SRCDIR
   rsync -zr -f"+ */" -f"- *" -e "ssh " $SRCDIR "$DESTDIR"
   find . -type f | xargs -n1 -P$THREADS -I% rsync -azvt -e "ssh" % "$DESTDIR"/%
 
   DATE=`date`
   echo "EndingTime is $DATE " > /tmp/sync_to_aws.log 
