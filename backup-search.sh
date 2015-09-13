#!/bin/bash

#
# This script is to back up critical Fluigidentity search data, keystore, backup the couchbase, and backup cloudpass
# Written: Bill Nguyen
# Date:	2014/02/10
# Rev: 1

DATE=`date '+%Y-%m-%d-%H:%M:%S'`
IPADDRESS=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | cut -d":" -f2 `

### BACKUP Search
echo "Backing up search data"
if [ ! -e /data/backup/search ]; then
  mkdir -p /data/backup/search
fi
cd /data
tar -zcvf totvslabs.tar.gz totvslabs/
rm -rf backup/search/totvslabs.tar.gz
mv totvslabs.tar.gz backup/search/totvslabs.tar.gz
sleep 20
