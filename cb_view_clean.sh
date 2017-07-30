#!/bin/bash

function usage {
	echo "Usage: $1 <CB_Host> <view_list_file>"
}

echo "Test if CURL is installed and is in the path."
which curl
RESULT=$?
[ $RESULT -ne 0 ] && echo "Curl is not installed or the 'curl_install_dir' is not in the PATH" && usage $0 && exit 1
curl --version

# default values
hostname="localhost"
bucketName="cloudpass"
filename="cb_view_list.txt"

[ "$1" != "" ] && hostname="$1"
[ "$2" != "" ] && [ -e "$2" ] && filename="$2"

echo "check if hostname and bucket name are valid."
echo "curl -X GET \"http://$hostname:8092/$bucketName\""
curl -X GET "http://$hostname:8092/$bucketName"
RESULT=$?
[ $RESULT -ne 0 ] && echo "Either the host name or the bucket name specified is not valid." && usage $0 && exit 1
echo ""

echo "Deleting the design document at http://$hostname:8092/$bucketName/_design/dev_cu"
echo "curl -X DELETE \"http://$hostname:8092/$bucketName/_design/dev_cu\""
curl -X DELETE "http://$hostname:8092/$bucketName/_design/dev_cu"
RESULT=$?
[ $RESULT -ne 0 ] && echo "Either the host name or the bucket name specified is not valid." && usage $0 && exit 1
echo ""

echo "Create the design document and the view at http://$hostname:8092/$bucketName/_design/dev_cu"
echo "curl -X PUT -H \"Content-Type: application/json\" \"http://$hostname:8092/$bucketName/_design/dev_cu\" -d @$filename"
curl -X PUT -H "Content-Type: application/json" "http://$hostname:8092/$bucketName/_design/dev_cu" -d @$filename
[ $RESULT -ne 0 ] && echo "Either the host name or the bucket name specified is not valid." && usage $0 && exit 1
echo ""

sleep 2
echo ""

echo "The views existing at \"http://$hostname:8092/$bucketName/_design/dev_cu\" are"
echo ""
curl -X GET "http://$hostname:8092/$bucketName/_design/dev_cu"
echo ""
