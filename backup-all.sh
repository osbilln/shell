#!/bin/bash
set -x 

# service ntp stop
# ntpdate -s pool.ntp.org
# service ntp start
DATE=`date '+%Y-%m-%d-%H:%M:%S'`
BACKUPDIR=/data/backup
### Backup Cloudpass 

if [ ! -e /data/backup/fluigidentity ]; then
  mkdir -p $BACKUPDIR/fluigidentity
fi
cp -rp /cloudpass $BACKUPDIR/fluigidentity/cloudpass.$DATE

service search stop
service rest stop
sleep 10
### BACKUP Search
if [ ! -e $BACKUPDIR/search ]; then
  mkdir -p /data/backup/search
fi

cd /data
tar -zcvf totvslabs.tar.gz totvslabs/
mv totvslabs.tar.gz $BACKUPDIR/search/totvslabs.tar.gz.$DATE
sleep 10
service search start
service rest start

