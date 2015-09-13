#!/bin/bash

VMWARE_SERVER=10.165.4.190
CREDENTIAL="root:totvs123"
OPTS="--compress=9"
if [ $# -eq 2 ]; then
   ORIGIN=$1
   TO=$2
   # ovftool --compress=9 vi://root:totvs123@10.165.4.190/totvslabs-10 $To
   # ovftool $OPTS vi://root:totvs123@10.165.4.190/AIO-VicenteGoetten $TO
   ovftool --compress=9 -ds=datastore1 vi://root:totvs123@10.165.4.190/$ORIGIN $TO

else
    echo -e "\n\nUsage: $0 {From Origin Appliance} {To New Appliance Name}"
    echo -e "ex: $0 totvslabs-10 bnguyen.ovf\n\n"

fi
