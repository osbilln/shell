#!/bin/bash

# This script will compress and move old data files older than certain days
# Change the arguments below
work_dir='/home/srini/databasebackups/ibdata_shrink_scripts/'
source_dir='/data1/mysql-data/'
logfile1="/tmp/all-db-drop-table.log"
tmpdir='/tmp'
#Below are the most important parameters
MYSQL="mysql $DB -A"

cd $work_dir

# Get all the available schema
#$MYSQL "select SCHEMA_NAME from information_schema.SCHEMATA where SCHEMA_NAME not in ('mysql','information_schema')">$work_dir/all-db-list.txt

touch $logfile1
echo `date` > $logfile1

while read db
do
        echo "Running drop table statements for $db ...before the shrink" >> $logfile1
	$MYSQL < $work_dir/drop_table_${db}.sql
	echo "Completed running drop table statements" >> $logfile1
done < $work_dir/all-db-list.txt
