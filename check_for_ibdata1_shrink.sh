#!/bin/bash

# This script will compress and move old data files older than certain days
# Change the arguments below
work_dir='/home/srini/databasebackups/ibdata_shrink_scripts_after_first_run/'
source_dir='/data1/mysql-data/'
logfile1="/tmp/all-db-list-after-first-run.log"
tmpdir='/tmp'
#Below are the most important parameters
MYSQL="mysql $DB -A --skip-column-names -BCe"

cd $work_dir

# Get all the available schema
$MYSQL "select SCHEMA_NAME from information_schema.SCHEMATA where SCHEMA_NAME not in ('mysql','information_schema')">$work_dir/all-db-list-after-first-run.txt

touch $logfile1
echo `date` > $logfile1

echo "Finding if there are tables which still use InnoDB" > $work_dir/table_count_after_first_run.txt
while read db
do
        echo "Checking if there are tables in $db ...which still use InnoDB" >> $logfile1
	$MYSQL "select '${db}'" >> $work_dir/table_count_after_first_run.txt
	$MYSQL "select concat('select count(*) from ' ,table_name,' ;') from information_schema.tables where table_schema = '${db}' and engine = 'InnoDB' ;" >> $work_dir/table_count_after_first_run.txt
	echo "Completed check for ${db}" >> $logfile1
done < $work_dir/all-db-list-after-first-run.txt

#cd $source_dir

#find . -name '*.gz' | xargs -I {} mv {} /mysqltmp/tmp-parking/

#mail -s "`hostname` - List of schemas which are inactive" srinib@naehas.com < $logfile2
