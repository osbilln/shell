#!/bin/bash
 
# SETUP OPTIONS
export SRCDIR="/data1"
export DESTDIR="/data2"
export THREADS="8"

date > /tmp/sync_to_nimble.log 
# RSYNC DIRECTORY STRUCTURE
rsync -zr -f"+ */" -f"- *" $SRCDIR/ $DESTDIR/ 
# FOLLOWING MAYBE FASTER BUT NOT AS FLEXIBLE
# cd $SRCDIR; find . -type d -print0 | cpio -0pdm $DESTDIR/
# FIND ALL FILES AND PASS THEM TO MULTIPLE RSYNC PROCESSES
cd $SRCDIR; find . ! -type d -print0 | xargs -0 -n1 -P$THREADS -I% rsync -azvt % $DESTDIR/% 
 
 
date >> /tmp/sync_to_nimble.log 
# IF YOU WANT TO LIMIT THE IO PRIORITY, 
# PREPEND THE FOLLOWING TO THE rsync & cd/find COMMANDS ABOVE:
#   ionice -c2
