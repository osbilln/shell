#!/bin/bash

#makes the script stop if there is an error
set -e

# Refresh Mongo Database Script
# This script connects to cpfmongodev to pull down a mongo database dump in bz2 format and then untar's it and does a data import on it.
# Note, you can pass in a local database name that you want the downloaded mongo database to be imported into.
# Please note that this database name that you type in will be dropped and then recreated.
#  
# If you do not type in a database name, it will use by default protools
#
# How to use this script:
# sh {scriptName} {dbName}
# sh ./download_and_refresh_local_mongo_db.sh protools 
#

USERNAME=${USER}
HOST="tools.cpfdev.com"
HOSTLOCATION="/home/qaprep"
HOSTFILENAME="mongo_backup.tar.bz2"

TEMPFILEPATH="/tmp"

MONGOUSERNAME="cpf_spt"
MONGOPASSWORD="sunshine"
MONGODBNAME="protools"

if [ -n "$1" ]
then
MONGODBNAME=$1
fi

echo "Beginning Refresh OF Mong Database Script"

echo "Connecting to remote machine to pull down file"
scp ${USERNAME}@${HOST}:${HOSTLOCATION}/${HOSTFILENAME} ${TEMPFILEPATH}
#for users who need to restore databases frequently
#cp  ${TEMPFILEPATH}/${HOSTFILENAME} ${HOME}/Desktop/${HOSTFILENAME}
echo "File has been pulled down"

echo "Untaring dude - this will take about a few minutes"
tar xjf ${TEMPFILEPATH}/${HOSTFILENAME} -C ${TEMPFILEPATH}
echo "I'm done gunziping"

echo "Restoring mongo database: ${MONGODBNAME}"

mongorestore --db ${MONGODBNAME} --drop /tmp/mongodump/protools

# Upon completion, cleanup...
echo "Database restore complete. Removing working files ... "
rm -rf ${TEMPFILEPATH}/mongodump

echo "The mongo database ${MONGODBNAME} has been refreshed .... now go away :-)"
