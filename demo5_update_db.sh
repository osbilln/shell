# This requires sshpass installed on the server running this script
# To install:
# sudo apt-get install sshpass

#!/bin/bash

# Change into our working directory
cd /backups/mysql/

USERNAME="ttam"
PASSWORD="sunshine"
HOST="tools.cpfdev.com"
HOSTDIR="/home/qaprep"
HOSTFILE="backup_post_refresh.sql.gz"

MYSQLUSERNAME="cpf_spt"
MYSQLPASSWORD="sunshine"
MYSQLDBNAME="protools_demo5"

if [ -n "$1" ]
then
MYSQLDBNAME=$1
fi

echo "beginning refresh script\n\n"

echo "removing the existing backup_post_refresh.sql"
rm backup_post_refresh.sql
echo "old file has been removed!\n\n"

echo "connecting to remote machine to pull down file"
export SSHPASS=$PASSWORD
sshpass -e sftp -oBatchMode=no -b - $USERNAME@$HOST << !
   cd $HOSTDIR
   get $HOSTFILE
   bye
!
#scp $USERNAME@$HOST:$HOSTFILE .
echo "file has been pulled down\n\n"

echo "gunziping dude - this will take about a minute or two"
gunzip ./backup_post_refresh.sql.gz
echo "I'm done gunziping\n\n"

echo "connecting to mysql to drop and create database $MYSQLDBNAME"
mysql -u$MYSQLUSERNAME -p$MYSQLPASSWORD -e "DROP DATABASE IF EXISTS $MYSQLDBNAME; CREATE DATABASE IF NOT EXISTS $MYSQLDBNAME;"
echo "Drop and create was good\n\n"

echo "About to run import of the unziped file -backup_post_refresh.sql into the db $MYSQLDBNAME"
echo "This will take a few minutes, so treat yourself to some coffee or sugar"

mysql -u$MYSQLUSERNAME -p$MYSQLPASSWORD $MYSQLDBNAME < ./backup_post_refresh.sql

echo "The database $MYSQLDBNAME has been refreshed .... now go away :-)\n\n"


# Run database change
# no need to run this, copy from dev already has been updated
#mysql $MYSQLDBNAME -u$MYSQLUSERNAME -p$MYSQLPASSWORD --force </home/spt/demo5/application/configs/database_changes.sql