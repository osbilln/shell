#!/bin/sh 

RSYNC=/usr/bin/rsync 
OPTS="-arltDvu --modify-window=1 --progress --delete"
SSH=/usr/bin/ssh 
KEY=/root/.ssh/id_rsa
RUSER=root
RHOST=10.28.207.233
RPATH=/var/www/
LPATH=/var/www/

$RSYNC $OPTS -e "$SSH -i $KEY" $RUSER@$RHOST:$RPATH $LPATH 