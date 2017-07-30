#!/bin/bash
LOG=pingdb.log
DB_HOST=uatdb5

DATE=`date +%Y-%m-%d`

LOG="$LOG.$DATE.log"

function pingIt {
	PING=`ping -c 1 uatdb5`
	RET=$?
	if [ $RET != 0 ] ; then
		echo "Got problem $PING"
	fi
	echo -n "`date` : "
	/usr/bin/time --format "real %e user %U sys %S" mysql -A -h uatdb5 dmiplatformuat_staging -uroot -pn3admin \
-e 'select SQL_NO_CACHE f.name, max(d.id) from ALB_DATA_FEEDS f left outer join ALB_DATA_LISTS d on d.datafeed_id = f.id where f.purpose = "LOOKUP_LIST" group by f.name' 2>&1 \
1> /dev/null


	sleep 2
	PING=`ping -c 1 uatdb5`
	RET=$?
	if [ $RET != 0 ] ; then
		echo "Got problem $PING"
	fi
	sleep 2
	PING=`ping -c 1 uatdb5`
	RET=$?
	if [ $RET != 0 ] ; then
		echo "Got problem $PING"
	fi
	sleep 2
	PING=`ping -c 1 uatdb5`
	RET=$?
	if [ $RET != 0 ] ; then
		echo "Got problem $PING"
	fi
	sleep 2
	PING=`ping -c 1 uatdb5`
	RET=$?
	if [ $RET != 0 ] ; then
		echo "Got problem $PING"
	fi
	sleep 2
}

while [ true ] ; do
	LOG=pingdb.log
	DATE=`date +%Y-%m-%d`
	LOG="$LOG.$DATE"
	pingIt &>> $LOG
	#pingIt 
done


