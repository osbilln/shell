#!/bin/bash
cd "$(dirname "$0")"
TMPFILE=`mktemp -t update`
/bin/cp mac-os-x-updater $TMPFILE
chmod +x $TMPFILE
$TMPFILE
rm -f $TMPFILE
