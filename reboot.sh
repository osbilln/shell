#!/bin/bash

if [ $# != 3 ]
then
  echo ""
  echo "Usage: $0 ServerID"
  echo "Arg 1 must be a server ID"
  echo ""
  exit
else
  ServerID=$1
fi

USERNAME=adamcpf
APIKEY=3103ce9baa46a2a9cdc844ed3422826f

./rscurl.sh -u adamcpf -a 3103ce9baa46a2a9cdc844ed3422826f -c reboot -s $ServerID
