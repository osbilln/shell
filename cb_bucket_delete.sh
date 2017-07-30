#!/bin/bash

# default values
hostName="localhost"
userName="Administrator"
password="password"
bucketName="cloudpass"
bucketPort="11211"
cbDefaultBucketName="cloudpass"
sessionBucketName="appsession"

# verify default and exit on missing values
if [ $# -eq 0 ] || [ "$1" == "" ]; then
	echo "No parameter passed, use default for all."
else
	hostName = $1
	if [ "$2" != "" ]; then
	     userName = $2
	fi
	if [ "$3" != "" ]; then
	     password = $3
	fi
fi

# echo the final decision on values
echo "==========================="
echo "Using the following"
echo ""
echo "  host = $hostName"
echo "  user = $userName"
echo "  password = $password"
echo "  bucketName = $bucketName"
echo "  bucketPort = $bucketPort"

# process
echo "==========================="
echo "Buckets on Host : $hostName"
echo ""
couchbase-cli bucket-list -c $hostName:8091
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "hostName ($hostName) is invalid."
	exit 1
fi

echo "==========================="
echo "Delete bucket : $cbDefaultBucketName"
echo ""
couchbase-cli bucket-delete \
  -c $hostName:8091 \
  --user=$userName \
  --password=$password \
  --bucket=$cbDefaultBucketName
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "Delete bucket failed."
fi

echo "==========================="
echo "Delete bucket : $sessionBucketName"
echo ""
couchbase-cli bucket-delete \
  -c $hostName:8091 \
  --user=$userName \
  --password=$password \
  --bucket=$sessionBucketName \
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "Delete bucket failed."
fi

couchbase-cli bucket-list -c $hostName:8091
