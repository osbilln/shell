#!/bin/bash

if [ $# != 2 ]
then
  echo ""
  echo "Usage: $0 ImageName ServerID"
  echo "Arg 1 must be a ImageName (dev, qa ,  etc.....)"
  echo "Arg 2 must be a ServerID "
  echo ""
  exit
else
  IMAGENAME=$1
  SERVERID=$2
fi

USERNAME=sequentsw
APIKEY=c105f49bbf3e18af9f9a5ce143350721
./rscurl.sh -u sequentsw -a c105f49bbf3e18af9f9a5ce143350721 -c create-image -n $IMAGENAME -s $SERVERID
