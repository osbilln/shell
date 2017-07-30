#!/bin/bash
# Checks if slave is caught up with replication

PASSWORD=n3admin
MYSQL="mysql --socket=/var/lib/mysql/db7.sock -uroot -p$PASSWORD -A -s"

while true
do
	echo "show processlist;" |  $MYSQL 
	SLAVESTATUS=`echo "show processlist;" |  $MYSQL | grep 'Has read all relay log' | wc -l `
#	echo $SLAVESTATUS
#	if [[ "$SLAVESTATUS" = "Has read all relay log" ]] ; then
	if [[ $SLAVESTATUS -eq 1 ]] ; then
		echo Slave caught up
		exit 0
	fi
        sleep 2
done


