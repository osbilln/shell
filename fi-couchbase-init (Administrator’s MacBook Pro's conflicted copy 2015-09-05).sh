#!/bin/bash

# variables
cb_user="Administrator"
cb_pass="password"
cb_host="127.0.0.1"
cb_port="8091"
fi_quota="300"
fi_buckets="cloudpass:couchbase:11222:100,Activity:couchbase:11224:100,SessionInfo:memcached:11226:100"


# get parameters
if [ $# -eq 2 ]; then
  cb_user=$1
  cb_pass=$2
fi
if [ $# -eq 4 ]; then
  cb_host=$3
  cb_port=$4
fi


# print parameters used
echo "CB User: $cb_user"
echo "CB Pass: $cb_pass"
echo "CB Host: $cb_host"
echo "CB Port: $cb_port"


# delete existing buckets
couchbase-cli bucket-list -c ${cb_host}:${cb_port} -u $cb_user -p $cb_pass | egrep "^[A-Za-z]+" | while read bucket; do
  echo "Deleting bucket [${bucket}] ..."
  couchbase-cli bucket-delete -c ${cb_host}:${cb_port} -u $cb_user -p $cb_pass --bucket=${bucket}
done


# make sure we have right quota for cluster
couchbase-cli cluster-init -c ${cb_host}:${cb_port} -u $cb_user -p $cb_pass --cluster-init-ramsize=${fi_quota}


# create new buckets
echo $fi_buckets | tr ',' '\n' | while read bucket_info; do
  bucket_name=$(echo $bucket_info | cut -d":" -f1)
  bucket_type=$(echo $bucket_info | cut -d":" -f2)
  bucket_port=$(echo $bucket_info | cut -d":" -f3)
  bucket_size=$(echo $bucket_info | cut -d":" -f4)
  echo "bucket_name: $bucket_name"
  echo "bucket_type: $bucket_type"
  echo "bucket_port: $bucket_port"
  echo "bucket_size: $bucket_size"

  couchbase-cli bucket-create -c ${cb_host}:${cb_port} -u $cb_user -p $cb_pass \
    --bucket=${bucket_name} \
    --bucket-type=${bucket_type} \
    --bucket-port=${bucket_port} \
    --bucket-ramsize=${bucket_size} \
    --enable-flush=1 
done
