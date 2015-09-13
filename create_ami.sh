#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
    echo "create_ami.sh usage: <aws access key> <aws secret key>"
    exit
fi

if [[ -d vendor/cookbooks ]]; then
    rm -r vendor/cookbooks
fi

bundle exec berks vendor vendor/cookbooks
packer build -var "env=production" -var "es_security_group=appindex-production" -var "aws_access_key=$1" -var "aws_secret_key=$2" -var "itype=r3.xlarge" -var "v_type=hvm" -var "ami=ami-5189a661" packer.json
