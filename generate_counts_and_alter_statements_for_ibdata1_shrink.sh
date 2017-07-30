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
$MYSQL "select SCHEMA_NAME from information_schema.SCHEMATA where SCHEMA_NAME not in ('mysql','information_schema')">$work_dir/all-db-list.txt

touch $logfile1
echo `date` > $logfile1

while read db
do
        echo "Getting counts for $db ...before the export" >> $logfile1
	$MYSQL "select concat('use ', '${db}', ';')" > $work_dir/table_count_${db}_before_export.txt
	$MYSQL "select concat('select count(*) from ' ,table_name,' ;') from information_schema.tables where table_schema = '${db}' and engine = 'InnoDB' and table_name not in ( (select TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}' union select REFERENCED_TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}') );" >> $work_dir/table_count_${db}_before_export.txt
        echo "Getting alter statements for $db ...before the shrink (to MyISAM)" >> $logfile1
	$MYSQL "select concat('use ', '${db}', ';')" > $work_dir/alter_table_myisam_${db}.sql
	$MYSQL "select concat('alter table ' ,table_name,' engine=MyISAM;') from information_schema.tables where table_schema = '${db}' and engine = 'InnoDB' and table_name not in ( (select TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}' union select REFERENCED_TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}') );" >> $work_dir/alter_table_myisam_${db}.sql
        echo "Getting alter statements for $db ...after the shrink (to InnoDB back)" >> $logfile1
	$MYSQL "select concat('use ', '${db}', ';')" > $work_dir/alter_table_innodb_${db}.sql
	$MYSQL "select concat('alter table ' ,table_name,' engine=InnoDB;') from information_schema.tables where table_schema = '${db}' and engine = 'InnoDB' and table_name not in ( (select TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}' union select REFERENCED_TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}') );" >> $work_dir/alter_table_innodb_${db}.sql
        echo "Getting exports for $db ...before the export" >> $logfile1
	$MYSQL "select concat('mysqldump ${db} --single-transaction ',table_name,' > ${db}_',table_name,'_mysqldump.sql') from information_schema.tables where table_schema = '${db}' and engine = 'InnoDB' and table_name in ( (select TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}' union select REFERENCED_TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}') );" >> $work_dir/mysqldump_${db}.sh
        echo "Getting exports for $db ...before the export" >> $logfile1
	$MYSQL "select concat('mysql ${db} < ${db}_',table_name,'_mysqldump.sql') from information_schema.tables where table_schema = '${db}' and engine = 'InnoDB' and table_name in ( (select TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}' union select REFERENCED_TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}') );" >> $work_dir/mysqlimport_${db}.sh
        echo "Getting drop tables for $db ...before the export" >> $logfile1
	$MYSQL "select concat('use ', '${db}', ';')" > $work_dir/drop_table_${db}.sql
	$MYSQL "select concat('set foreign_key_checks = 0', ';')" >> $work_dir/drop_table_${db}.sql
	$MYSQL "select concat('drop table if exists ',table_name,';') from information_schema.tables where table_schema = '${db}' and engine = 'InnoDB' and table_name in ( (select TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}' union select REFERENCED_TABLE_NAME from information_schema.REFERENTIAL_CONSTRAINTS where CONSTRAINT_SCHEMA = '${db}') );" >> $work_dir/drop_table_${db}.sql
	$MYSQL "select concat('set foreign_key_checks = 1', ';')" >> $work_dir/drop_table_${db}.sql
	echo "Completed generating count and alter statements" >> $logfile1
done < $work_dir/all-db-list.txt

#cd $source_dir

#find . -name '*.gz' | xargs -I {} mv {} /mysqltmp/tmp-parking/

#mail -s "`hostname` - List of schemas which are inactive" srinib@naehas.com < $logfile2
