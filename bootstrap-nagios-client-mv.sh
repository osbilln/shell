#!/bin/bash


CLOUDPASS=/Users/billnguyen/chef/totvs/keys/CloudpassServers.pem
BILLKEY=~/.ssh/id_rsa

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` server name etc."
  exit $E_BADARGS
fi

SERVER=$1

knife bootstrap $SERVER \
	--ssh-user root \
#	-i $BILLKEY \
 	--sudo \
	--run-list 'role[chef-nagios-client]' 
