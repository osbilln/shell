#!/bin/bash

########################################################
# DOWNLOAD DB
#
#
########################################################

#makes the script stop if there is an error
set -e

# Refresh Database Script
# This script connects to cpfdev to pull down a database dump in gz format and then unzip its and does a data import on it.
# Please note that the database name called protools will be deleted and a new DB name by protools will be created.
#  
# How to use this script:
# sh {scriptName}
# sh ./fast_refresh_local_db.sh 
#

echo "Enter your username: "
read ANSWER
echo You typed: "$ANSWER"
USERNAME="$ANSWER"
HOST="tools.cpfdev.com"
HOSTLOCATION="/home/qaprep"
HOSTFILENAME="backup_post_refresh.sql.gz"
HOSTFILENAMEUNZIPPED="backup_post_refresh.sql"

TEMPFILEPATH="/tmp"

MYSQLUSERNAME="cpf_spt"
MYSQLPASSWORD="sunshine"
MYSQLDBNAME="protools"

if [ -n "$1" ]
then
MYSQLDBNAME=$1
fi

echo "Beginning Database Refresh"

if [ -e ${TEMPFILEPATH}/{HOSTFILENAME} ]; then
	echo "Removing the existing backup file"
		/bin/rm "${TEMPFILEPATH}/backup_post_refresh.sql"
	echo "Old file successfully removed"
fi 

echo "Connecting to remote machine to pull down the sqldump file"
scp ${USERNAME}@${HOST}:${HOSTLOCATION}/${HOSTFILENAME} ${TEMPFILEPATH}
#for users who need to restore databases frequently
cp  ${TEMPFILEPATH}/${HOSTFILENAME} ${HOME}/Desktop/${HOSTFILENAME}
echo "File has been pulled down"

echo "Gunzipping dude - this will take about 3 minutes"
gunzip ${TEMPFILEPATH}/${HOSTFILENAME}
echo "I'm done gunzipping"

########################################################
# REFRESH LOCAL DB
#
#
########################################################


# Refresh Database Script
# This script only does a data import of an already downloaded gz file.
# Note, you can pass in a local database name that you want the downloaded database to be imported into.
# Please note that this database name that you type in will be dropped and then recreated.
#  
# If you do not type in a database name, it will use by default protools
#
echo "$TEMPFILEPATH/$HOSTFILENAMEUNZIPPED";

if [ ! -e $TEMPFILEPATH/$HOSTFILENAMEUNZIPPED ]; 
then
	echo "Sql file was not found. Import will not continue. Please download a fresh sql file."
	exit 1
fi

echo "Beginning just data load script\n"

echo "Connecting to mysql to drop and create database $MYSQLDBNAME"
/opt/local/lib/mysql5/bin/mysql -u$MYSQLUSERNAME -p$MYSQLPASSWORD -e "DROP DATABASE IF EXISTS $MYSQLDBNAME; CREATE DATABASE IF NOT EXISTS $MYSQLDBNAME;"
echo "Drop and create was good\n"

echo "About to run import of the unzipped file -backup_post_refresh.sql into the db $MYSQLDBNAME"
echo "This will take a few minutes, so treat yourself to some coffee or sugar"

START=`date +%s`

(
     echo "SET AUTOCOMMIT=0;"
     echo "SET UNIQUE_CHECKS=0;"
     echo "SET FOREIGN_KEY_CHECKS=0;"
     cat "/tmp/backup_post_refresh.sql"
     echo "SET FOREIGN_KEY_CHECKS=1;"
     echo "SET UNIQUE_CHECKS=1;"
     echo "SET AUTOCOMMIT=1;"
     echo "COMMIT;"
 ) | mysql -u"$MYSQLUSERNAME" -p"$MYSQLPASSWORD" $MYSQLDBNAME

"The database $MYSQLDBNAME has been refreshed .... now go away :-)\n"

FINISH=`date +%s`

ELAPSED=`expr $FINISH - $START`
echo "Time to import the DB: $ELAPSED seconds \n"
