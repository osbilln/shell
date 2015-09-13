#!/bin/bash 
set -x

DATE=`date +"%Y-%m-%d_%H%M"`
###LOGLOC="/apps/cloudant/dumps"
LOGLOC="."

### Set source information
CLOUDANT_SOURCE_USER="artemis-uat"
CLOUDANT_SOURCE_PASS="cuw+_ucahuf-U8ra"
CLOUDANT_SOURCE_URL="${CLOUDANT_SOURCE_USER}.cloudant.com"

####Set backup information
CLOUDANT_BACKUP_USER="billn"
# CLOUDANT_BACKUP_PASS=`echo at2mJvOuND6n | base64 --decode`
CLOUDANT_BACKUP_PASS="at2mJvOuND6n"
CLOUDANT_BACKUP_URL="${CLOUDANT_BACKUP_USER}.cloudant.com"

### Start logging
echo Start $1 backup `date` >> $LOGLOC/cloudantBackup.log

### Get list of all databases.  Databases are dependent on the wallets registered and are dynamic.
line=`curl -X GET https://${CLOUDANT_SOURCE_USER}:${CLOUDANT_SOURCE_PASS}@${CLOUDANT_SOURCE_URL}/_all_dbs`
###print out list of databases as debug
echo "Databases: $line" >> $LOGLOC/cloudantBackup.log;  ###debug code

### Get databases name and backup
IFS=",\"\]\[\s" read -ra arr <<< "$line"
	for i in "${arr[@]}"
	do
		### echo $i		###Debug code  
		### strip database name of unwanted characters
		## dbs=`echo $i | sed 's/\s//g' | sed 's/\[//g' | sed 's/\]//g'| sed 's/\"//g'`
		###echo "Backing up $dbs"  >> $LOGLOC/cloudantBackup.log ;
		CLOUDANT_DB=$dbs
		### select backup type
		case "$1" in
			inc|incremental|Inc)
				BACKUP_NAME=${CLOUDANT_DB} 
				##echo "Incremental backup of database to same name $CLOUDANT_DB" >> $LOGLOC/cloudantBackup.log ;
				## create database only on initial setup or database cleanup
				###CURLRSP=`curl -v -X PUT "https://${CLOUDANT_BACKUP_USER}:${CLOUDANT_BACKUP_PASS}@${CLOUDANT_BACKUP_URL}/${BACKUP_NAME}" -g`
				;;
			*)
				BACKUP_NAME="${CLOUDANT_DB}_backup_${DATE}" 
				##echo "Creating database named ${BACKUP_NAME}" >> $LOGLOC/cloudantBackup.log ;
				### First, create the database for full backup
				CURLRSP=`curl -v -X PUT "https://${CLOUDANT_BACKUP_USER}:${CLOUDANT_BACKUP_PASS}@${CLOUDANT_BACKUP_URL}/${BACKUP_NAME}" -g`
				;;
		esac
		echo "Starting replication..." >> $LOGLOC/cloudantBackup.log ;
		# # # # Next, tell the replicator to copy the source database to the new backup database
		CURLRSP=`curl -X POST "https://${CLOUDANT_SOURCE_USER}:${CLOUDANT_SOURCE_PASS}@${CLOUDANT_SOURCE_URL}/_replicate" \
			-d '{"source":"https://'${CLOUDANT_SOURCE_USER}':'${CLOUDANT_SOURCE_PASS}'@'${CLOUDANT_SOURCE_URL}'/'${CLOUDANT_DB}'", \
			"target":"https://'${CLOUDANT_BACKUP_USER}':'${CLOUDANT_BACKUP_PASS}'@'${CLOUDANT_BACKUP_URL}'/'${BACKUP_NAME}'"}' \
			-H "Content-type: application/json" -gecho "All done."`
	done;
	
# ### debug code:  Echo number of elements in array
echo "Number of databases backed up" ${#arr[@]} >> $LOGLOC/cloudantBackup.log;
echo END `date` >> $LOGLOC/cloudantBackup.log