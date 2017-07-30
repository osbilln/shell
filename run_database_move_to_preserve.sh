#!/bin/bash

# This script will compress and move old data files older than certain days
# Change the arguments below
work_dir='/home/srini/databasebackups/ibdata_shrink_scripts/'
source_dir='/data1/mysql-data/'
dest_dir='/data1/databases-to-be-preserved/'
dest_dir_ibdata_to_be_preserved='/data1/ibdata-to-be-preserved/'
logfile1="/tmp/all-db-database-move-to-preserve.log"
tmpdir='/tmp'
#Below are the most important parameters
MYSQL="mysql $DB -A"

cd $work_dir

mkdir -p $dest_dir
mkdir -p $dest_dir_ibdata_to_be_preserved

mv $source_dir/ib* $dest_dir_ibdata_to_be_preserved

# Get all the available schema
#$MYSQL "select SCHEMA_NAME from information_schema.SCHEMATA where SCHEMA_NAME not in ('mysql','information_schema')">$work_dir/all-db-list.txt

touch $logfile1
echo `date` > $logfile1

while read db
do
        echo "Running database move commands for $db ...to preserve them....before the shrink" >> $logfile1
	echo "Moving $db now"
	mv $source_dir/${db} $dest_dir
	echo "Completed running mysqldump for $db" >> $logfile1
done < $work_dir/all-db-list.txt
