#!/bin/sh
# Shutdown, copy log4j.properties, startup, and then tail the log file.
# A. Cin

./shutdown.sh
ECHO=/bin/echo
$ECHO -n 'Starting in '
$ECHO -n '3...'
sleep 1
$ECHO -n '2...'
cp ../conf/log4j.properties ../webapps/dashboard/WEB-INF/classes/
sleep 1
$ECHO -n '1...'
sleep 1
$ECHO '0...'
./startup.sh
sleep 1
TODAY=`date +%Y-%m-%d`
while [ ! -f ../logs/dashboard.log.$TODAY ] ; do
  echo 'No log yet.'
  sleep 1
done

exec tail -F ../logs/dashboard.log.$TODAY

