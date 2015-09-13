#!/bin/sh
# Usage: makeSshKeys.sh KEYNAME PASSPHRASE
#
# A. Cin

HERE=`dirname $0`
cd $HERE
MACHINE_ID=$1
PHRASE=$2
if [[ "x$PHRASE" = "x" ]] ; then
    echo 'Phrase is required'
    exit 1
fi
DEST=../temp/ssh

if [ -f $DEST/$MACHINE_ID ] ; then
	echo 'Ssh key already exists.  Aborting.'
    exit 1
else
	mkdir -p $DEST
	ssh-keygen -t dsa -N "$PHRASE" -f $DEST/$MACHINE_ID
    exit $?
fi
