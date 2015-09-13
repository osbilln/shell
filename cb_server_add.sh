#!/bin/bash
set -x
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

echo "==========================="
echo "Add Server: $servername"
echo ""

couchbase-cli server-add -c 127.0.0.1:8091 -u ${userName} -p ${password} \
	--server-add=10.165.4.70:8091 \
	--server-add-username=${userName} \
	--server-add-password=${password}   

RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "Create bucket failed."
	exit 1
fi
