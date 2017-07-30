#!/bin/bash

if [ $# != 2 ]
then
  echo ""
  echo "Usage: $0 Servername ImageID ServerSize "
  echo "Arg 1 must be a servername (cpfsnapshot, rcpfweb01d etc.....)"
  echo "Arg 2 must be a ImageID (cpfsstandalone03: 23722603 etc.....)"
  echo "Arg 3 must be a Server Flavor (1=256K, 2=512K ,3=1GB,4=2GB ,5=4GB ,6=8GB, 7=16GB, 8=32GB)"
  echo ""
  exit
else
  SERVERID=$1
  SERVERFLAVOR=$2
fi

USERNAME=adamcpf
APIKEY=3103ce9baa46a2a9cdc844ed3422826f

./rscurl.sh -u adamcpf -a 3103ce9baa46a2a9cdc844ed3422826f -c resize -s $SERVERID -f $SERVERFLAVOR
