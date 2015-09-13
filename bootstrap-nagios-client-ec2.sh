#!/bin/bash


CLOUDPASS=/Users/billnguyen/chef/totvs/keys/CloudpassServers.pem
BILLKEY=~billnguyen/.ssh/id_rsa
# CHEF_SSH_PORT="--ssh-port 24075 \"
if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` server name etc."
  exit $E_BADARGS
fi

SERVER=$1

knife bootstrap $SERVER \
	--ssh-port 22 \
	--ssh-user root \
	-i $CLOUDPASS \
 	--sudo \
	--run-list 'role[chef-nagios-client]' 
