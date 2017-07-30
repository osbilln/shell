#!/bin/bash

if [ $# != 3 ]
then
  echo ""
  echo "Usage: $0 Servername ImageID ServerSize "
  echo "Arg 1 must be a servername (snapshot, fweb01d etc.....)"
  echo "Arg 2 must be a ImageID (standalone03: 23722603 etc.....)"
  echo "Arg 3 must be a Server Flavor (1=256K, 2=512K ,3=1GB,4=2GB ,5=4GB ,6=8GB, 7=16GB, 8=32GB)"
  echo ""
  exit
else
  SERVERNAME=$1
  SERVERIMAGEID=$2
  SERVERFLAVOR=$3
fi
USERNAME="sequentsw"
APIKEY="3103ce9baa46a2a9cdc844ed3422826f"

./rscurl.sh -u $USERNAME -a $APIKEY -c create-server -n $SERVERNAME -i 26600566 -f $SERVERFLAVOR
