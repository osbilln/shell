#!/bin/bash

# This script will compress and move old data files older than certain days
# Change the arguments below
work_dir='/home/srini/databasebackups/ibdata_shrink_scripts/'
source_dir='/data1/mysql-data/'
logfile1="/tmp/all-db-list.log"
tmpdir='/tmp'
#Below are the most important parameters
MYSQL="mysql $DB -A --skip-column-names -BCe"

cd $work_dir

# Get all the available schema
#$MYSQL "select SCHEMA_NAME from information_schema.SCHEMATA where SCHEMA_NAME not in ('mysql','information_schema')">$work_dir/all-db-list.txt


while read db
do
	$MYSQL "select concat('use ', '${db}', ';')" > $work_dir/drop_table_${db}.sql
	$MYSQL "select concat('set foreign_key_checks = 0', ';')" >> $work_dir/drop_table_${db}.sql
	$MYSQL "select concat('drop table if exists ',table_name,';') from information_schema.tables where table_schema = '${db}' and engine = 'InnoDB' and table_name in ( (select TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}' union select REFERENCED_TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}') );" >> $work_dir/drop_table_${db}.sql
	$MYSQL "select concat('set foreign_key_checks = 1', ';')" >> $work_dir/drop_table_${db}.sql
done < $work_dir/all-db-list.txt
