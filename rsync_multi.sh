#!/bin/bash

set -x 
# SETUP OPTIONS
if [ "$#" -ne 3 ]; then
    echo "usage: $0  <SOURCE> <DESTINATION> <LOGFILE>"
    echo "example: $0 /data5 /data1 mysqldata"
    exit
fi


DATE=`date`
echo "Starting Time is $DATE " > /tmp/sync_to_${3}.log 

   export SRCDIR="${1}"
   export DESTDIR="${2}"
   export THREADS="12"
 
   cd $SRCDIR
   rsync -zr -f"+ */" -f"- *"  "$SRCDIR" "$DESTDIR"
   find . -type f | xargs -n1 -P$THREADS -I% rsync -azvt % "$DESTDIR"/%
 
   DATE=`date`
   echo "EndingTime is $DATE " > /tmp/sync_to_${3}.log
