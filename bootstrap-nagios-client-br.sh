#!/bin/bash

BILLKEY=~/.ssh/sq_billn
if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` servername or ip etc."
  exit $E_BADARGS
fi

SERVER=$1

knife bootstrap $SERVER \
	--ssh-port 22 \
	--ssh-user root \
#	-i $BILLKEY \
# 	--sudo \
	--run-list 'role[chef-nagios-client]' 
