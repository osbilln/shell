#!/bin/bash

hostname="localhost"
if [ "$1" != "" ]; then 
   hostname=$1
fi

username="Administrator"
password="password"
cbDefaultBucketName="cloudpass"
sessionBucketName="appsession"


echo "Flushing buckets ..."
echo "hostname: $hostname"
echo "Main bucket name: $cbdefaultBucketName"
echo "Session bucket name: $sessionBucketName"

couchbase-cli bucket-flush -c ${hostname}:8091 --user=${userName} --password=${password} --bucket=${cbdefaultBucketName}
couchbase-cli bucket-flush -c ${hostname}:8091 --user=${userName} --password=${password} --bucket=${sessionBucketName}
