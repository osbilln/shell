#!/bin/bash

#makes the script stop if there is an error
# set -e

# Refresh Database Script
# This script connects to cpfdev to pull down a database dump in gz format and then unzip its and does a data import on it.
# Note, you can pass in a local database name that you want the downloaded database to be imported into.
# Please note that this database name that you type in will be dropped and then recreated.
#  
# If you do not type in a database name, it will use by default protools
#
# How to use this script:
# sh {scriptName} {dbName}
# sh ./download_and_refresh_local_db.sh protools 
#

USERNAME=${USER}
HOST="cpfnonproddb.com"
HOSTLOCATION="/home/qaprep"
HOSTFILENAME="backup_post_refresh.sql.gz"

TEMPFILEPATH="/tmp"

MYSQLUSERNAME="cpf_spt"
MYSQLPASSWORD="sunshine"
MYSQLDBNAME="protools"

if [ -n "$1" ]
then
MYSQLDBNAME=$1
fi

echo "Beginning Database Refresh"

if [ -e ${TEMPFILEPATH}/backup_post_refresh.sql ]; then
	echo "Removing the existing backup file"
		/bin/rm "${TEMPFILEPATH}/backup_post_refresh.sql"
	echo "Old file successfully removed"
fi 

echo "Connecting to remote machine to pull down the sqldump file"
scp ${USERNAME}@${HOST}:${HOSTLOCATION}/${HOSTFILENAME} ${TEMPFILEPATH}
#for users who need to restore databases frequently
#cp  ${TEMPFILEPATH}/${HOSTFILENAME} ${HOME}/Desktop/${HOSTFILENAME}
echo "File has been pulled down"

echo "Gunzipping dude - this will take about 3 minutes"
gunzip ${TEMPFILEPATH}/${HOSTFILENAME}
echo "I'm done gunzipping"

echo "Connecting to mysql to drop and create database ${MYSQLDBNAME}"
/opt/local/lib/mysql5/bin/mysql -u${MYSQLUSERNAME} -p${MYSQLPASSWORD} -e "DROP DATABASE IF EXISTS ${MYSQLDBNAME}; CREATE DATABASE IF NOT EXISTS ${MYSQLDBNAME};"
echo "Drop and create was good"

echo "About to run import of the unzipped file into the ${MYSQLDBNAME} database."
echo "This process currently takes 90-120 minutes, so treat yourself to some coffee or sugar..."

/opt/local/lib/mysql5/bin/mysql -u${MYSQLUSERNAME} -p${MYSQLPASSWORD} ${MYSQLDBNAME} < ${TEMPFILEPATH}/backup_post_refresh.sql

#restore the table structure of any tables that were omitted from the backup that was just restored
/opt/local/lib/mysql5/bin/mysql -u${MYSQLUSERNAME} -p${MYSQLPASSWORD} ${MYSQLDBNAME} < ../application/configs/run_after_backupsmall.sql

echo "The database ${MYSQLDBNAME} has been refreshed .... now restart mysql to recover memory and get to work!"
