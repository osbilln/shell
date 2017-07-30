#!/bin/bash

# This script will compress and move old data files older than certain days
# Change the arguments below
source_dir='/data5/mysql-data/'
logfile1="/tmp/db-list.log"
logfile2="/tmp/db-inactive-list.log"
tmpdir='/tmp'
#Below are the most important parameters
MYSQL="mysql $DB -A  -BCe"

# Split the master query into multiple small tables
$MYSQL "select distinct DB from information_schema.processlist where DB is not null and DB not in ('mysql','information_schema');"> $tmpdir/db-list.txt

touch $logfile1
echo `date` > $logfile1

while read db
do
        echo "Archiving the schema $db ..." >> $logfile1
        echo "./archive_datalists.sh $db" >> $logfile1
        ./archive_datalists.sh $db
        echo "Archive completed for $db " >> $logfile1
done < $tmpdir/db-list.txt

$MYSQL "select distinct schema_name from information_schema.SCHEMATA where schema_name not in (select distinct lower(DB) from information_schema.processlist where DB is not NULL) and schema_name not in ('mysql','information_schema');"> $tmpdir/db-inactive-list.txt

touch $logfile2
echo `date` > $logfile2

while read db
do
#        echo "Checking last modified date for the schema $db ..." >> $logfile2
	last_modified_time=`ls -ld $source_dir/$db | awk '{print $6}'`
#	echo $last_modified_time	
        echo "Last modified date for the schema $db is $last_modified_time " >> $logfile2
done < $tmpdir/db-inactive-list.txt

cd $source_dir

find . -name '*.gz' | xargs -I {} mv {} /mysqltmp/tmp-parking/

mail -s "`hostname` - List of schemas which are inactive" srinib@naehas.com < $logfile2
