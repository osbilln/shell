#!/bin/bash
# Checks if slave is caught up with replication

PASSWORD=n3admin
IPADDRESS=$1
MYSQL="mysql --socket=/var/lib/mysql/db7.sock -uroot -p$PASSWORD -A -s"
SLAVESTATUS=`echo "show slave status\G" | $MYSQL `
#SLAVESTOP=`echo "stop slave;" | $MYSQL `
#MASTERSTATUS=`echo "RESET MASTER;" | $MYSQL `
MASTERSTATUS=`echo "show master status\G" | $MYSQL `
echo $MASTERSTATUS
