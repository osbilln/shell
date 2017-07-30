#!/bin/sh

# This script will compress and move old data files older than certain days
# Change the arguments below
nofdays=14
sourcedir='/data2/db7/'
destinationdir='/data2/uatdb5/'
logfile='/tmp/tables-db7-comcastprod.log'
tmpdir='/tmp'
#Below are the most important parameters
DB='comcastprod_staging'
MYSQL="mysql $DB --socket=/var/lib/mysql/uatdb5.sock -A  -BCe"
#MYSQL_SOURCE="mysql $DB --socket=/var/lib/mysql/db7.sock -A  -BCe"

# Split the master query into multiple small tables
$MYSQL "DROP TABLE if exists old_staging_tables; CREATE TABLE old_staging_tables SELECT distinct tablename, LAST_MODIFIED_DATE from N_DATA_LISTS where type in ('DATA_FILE','TMP','STAGING') AND LAST_MODIFIED_DATE between date_sub(now(),INTERVAL $nofdays DAY) and date_sub(now(),INTERVAL 0 DAY)"

#$MYSQL_SOURCE " DROP TABLE IF EXISTS is_tablelist; CREATE TABLE is_tablelist select TABLE_NAME from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA = '$DB'; CREATE INDEX ix1 on is_tablelist(table_name)"

$MYSQL "SELECT a.tablename from old_staging_tables a"> $tmpdir/tablelist-$DB.txt
#$MYSQL "SELECT a.tablename from old_staging_tables a, is_tablelist b WHERE a.tablename=b.table_name"> $tmpdir/tablelist-$DB.txt

touch $logfile

while read table
do
        echo "Coopyig the files $table.* ..." >> $logfile
        echo "cp $sourcedir/$DB/$table.* $destinationdir/$DB/" >> $logfile
        cp $sourcedir/$DB/$table.* $destinationdir/$DB/
        echo "Copy completed for $table " >> $logfile
done < $tmpdir/tablelist-$DB.txt

