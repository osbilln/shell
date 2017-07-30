#!/bin/bash
APINEW="b9742c2d33bd0722d3f1c523c6004273"
APIKEY="c105f49bbf3e18af9f9a5ce143350721"
# APIKEY2=c105f49bbf3e18af9f9a5ce143350721
USER="sequentsw"
APIKEY=3103ce9baa46a2a9cdc844ed3422826f
# ./rscurl.sh -u adamcpf -a 3103ce9baa46a2a9cdc844ed3422826f -c list-servers
./rscurl.sh -u $USER -a $APINEW -c list-servers
