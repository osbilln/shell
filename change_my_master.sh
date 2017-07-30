#!/bin/bash
# Checks if slave is caught up with replication

echo $#
if [[ $# -le 0 ]] ; then
    echo 'Need two arguments'
    exit 0
fi

PASSWORD=n3admin
IPADDRESS=$1
echo IPADDRESS is $IPADDRESS
MYSQL="mysql --socket=/var/lib/mysql/db7.sock -uroot -p$PASSWORD -A -s"
echo ' '
echo "show slave status\G" | $MYSQL
echo ' '
#SLAVESTOP=`echo "stop slave;" | $MYSQL `
echo $SLAVESTOP
#MASTERSTATUS=`echo "CHANGE MASTER TO MASTER_HOST='${IPADDRESS}',MASTER_PORT = 3306,MASTER_USER = 'repl',MASTER_PASSWORD='6vFcW0xUctAFLb3DQLFkBfT34PvrE5I';" | $MYSQL `
echo ' '
echo "show slave status\G" | $MYSQL
echo ' '
#SLAVESTART=`echo "start slave;" | $MYSQL `
echo $SLAVESTART
echo ' '
echo "show slave status\G" | $MYSQL
echo ' '
