#!/bin/sh 

RSYNC=/usr/bin/rsync 
SSH=/usr/bin/ssh 
KEY=/root/.ssh/id_rsa
RUSER=root
RHOST=$1
DATE=`date '+%Y-%m-%d-%H:%M:%S'`
RPATH=/cloudpass/backend/build/bin/CloudpassKeystore
LPATH=/data/backup/keystore/CloudpassKeystore

scp -r -i "$KEY" $RUSER@$RHOST:"$RPATH" "$LPATH".$RHOST.$DATE
