#!/bin/bash
# Checks if slave is caught up with replication

PASSWORD=n3admin
MYSQL="mysql --socket=/var/lib/mysql/db7.sock -uroot -p$PASSWORD -A -s"
echo "show master status\G" | $MYSQL
#MASTERFLUSHSTATUS=`echo "FLUSH LOGS;" | $MYSQL `
echo $MASTERFLUSHSTATUS
echo "show master status\G" | $MYSQL
