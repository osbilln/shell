#!/bin/bash

# This script will compress and move old data files older than certain days
# Change the arguments below
nofdays=30
sourcedir='/data5/mysql-data/'
if [[ "$1" == "" ]] ; then
	DB='dmiimpperf'
else
        DB=$1
fi
echo $DB
logfile="/tmp/tablescompressed-perfdb1-{$DB}.log"
tmpdir='/tmp'
#Below are the most important parameters
MYSQL="mysql $DB -A  -BCe"

cd $sourcedir/$DB/
echo "Compressing the files $sourcedir/$DB/* ..." >> $logfile
echo "/bin/gzip $sourcedir/$DB/*" >> $logfile
/bin/gzip $sourcedir/$DB/*
echo "Compress completed for $table " >> $logfile

