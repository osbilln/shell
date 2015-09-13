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

knife bootstrap $SERVER
  --ssh-gateway user@gateway.ec2.example.com
  --ssh-user ubuntu
  --sudo
  --identity-file ~/.ssh/clarkdave.pem
  --environment production
  --node-name web1
  --run-list 'role[base],role[web_server]'

