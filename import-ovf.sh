#!/bin/bash

VMWARE_SERVER=10.165.4.190
USERNAME="root"
PASSWORD="totvs123"
OPTS="--powerOn"
if [ $# -eq 1 ]; then
   MASTER=$1
   ovftool --powerOn $MASTER vi://$USERNAME:$PASSWORD@10.165.4.190/
else
    echo -e "\n\nUsage: $0 {Virtual Appliance Name}"
    echo -e "ex: $0 bnguyen.ovf\n\n"

fi
