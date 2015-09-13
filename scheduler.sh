#!/bin/bash

# updater runtime monitor

# runtime.txt - the file containing the last time the updater run

# first we check if the file runtime.txt exists, and if not
# then we run the updater and create the file

cd "$(dirname "$0")"
RUNTIME_FILE="Runtime.ini"
RUN_UPDATER_FILE="./run_update.sh"
[ ! -f $RUNTIME_FILE ] && { (date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s") > $RUNTIME_FILE ; $RUN_UPDATER_FILE; }

# get the last runtime from a file
last_runtime=`cat $RUNTIME_FILE`

#check if the last runtime of updater was more that 12 hours ago
# if so, run it and update the time in runtime.txt file.
while true
do
    timeBefore12Hours=$(date -v -12H)
    #convert the times to seconds after epoch in order to make the comparison
    timeBefore12HoursAsEpoch=$(date -j -f "%a %b %d %T %Z %Y" "$timeBefore12Hours" "+%s")
    if [ "$timeBefore12HoursAsEpoch" -gt "$last_runtime" ]; # now - last_runtime > 12hours
    then
	$RUN_UPDATER_FILE
	last_runtime=$(date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s")
	(date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s") > $RUNTIME_FILE
    fi
    sleep 1
done





