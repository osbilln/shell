#!/bin/bash

# Refresh Database Script
# This script only does a data import of an already downloaded gz file.
# Note, you can pass in a local database name that you want the downloaded database to be imported into.
# Please note that this database name that you type in will be dropped and then recreated.
#  
# If you do not type in a database name, it will use by default protools
#

USERNAME=${USER}
HOST="tools.cpfdev.com"
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

if [ ! -e $TEMPFILEPATH/backup_post_refresh.sql ]; 
then
	echo "Sql file was not found. Import will not continue. Please download a fresh sql file."
	exit 1
fi

echo "Beginning just data load script\n"

echo "Connecting to mysql to drop and create database $MYSQLDBNAME"
/opt/local/lib/mysql5/bin/mysql -u$MYSQLUSERNAME -p$MYSQLPASSWORD -e "DROP DATABASE IF EXISTS $MYSQLDBNAME; CREATE DATABASE IF NOT EXISTS $MYSQLDBNAME;"
echo "Drop and create was good\n"

echo "About to run import of the unziped file -backup_post_refresh.sql into the db $MYSQLDBNAME"
echo "This will take a few minutes, so treat yourself to some coffee or sugar"

echo "About to run import of the unziped file -backup_post_refresh.sql into the db $MYSQLDBNAME"
echo "This will take a few minutes, so treat yourself to some coffee or sugar"
/opt/local/lib/mysql5/bin/mysql -u$MYSQLUSERNAME -p$MYSQLPASSWORD $MYSQLDBNAME < $TEMPFILEPATH/backup_post_refresh.sql

 "The database $MYSQLDBNAME has been refreshed .... now go away :-)\n"

