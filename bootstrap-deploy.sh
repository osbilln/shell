#!/bin/bash

APP=/Users/billnguyen/chef/totvs/keys/FluigIdentityProductionServers.pem
KEYSTORE=/Users/billnguyen/chef/totvs/keys/FluigIdentityProductionKeystoreServers.pem
CLOUDPASS=/Users/billnguyen/chef/totvs/keys/CloudpassServers.pem
BILLKEY=~billnguyen/.ssh/id_rsa

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` server name etc."
  exit $E_BADARGS
fi

SERVER=$1

knife bootstrap $SERVER \
	--ssh-port 22 \
	--ssh-user fluig \
	-i $APP\
 	--sudo \
	--run-list 'role[fi-aio-deploy]' 
