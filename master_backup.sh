#!/bin/bash -e
set -x
# 
# A simple backup script which when run on a production server (typicaly via cron) will push all of our data to some place you can rsync (e.g. rsync.net)
# 

LOG="/tmp/backup.log"
BACKUP_CONNECT='8456@usw-s008.rsync.net'
BASE_DEST=${BACKUP_CONNECT}:
RSYNC_COMMAND='/opt/local/bin/rsync'

function rsync_net () {
	echo "Starting backup to $BASE_DEST" 
	echo -e "\n\n" 
	ssh ${BACKUP_CONNECT} 'touch backup_start'

	echo "starting database backups: WOM_APPS_PROD "
	${RSYNC_COMMAND} -vaz /shared/db_backup/wom_apps/*dmp.gz ${BASE_DEST}db_backup/wom_apps/ 
	echo -e "\n\n" 
	echo "starting database backups: REDIRECT_PROD"
	${RSYNC_COMMAND} -vaz /shared/db_backup/redirect/*dmp.gz ${BASE_DEST}db_backup/redirect/
	echo -e "\n\n" 
	echo "starting database backups: REPORT_PROD"
	${RSYNC_COMMAND} -vaz /shared/db_backup/report/*dmp.gz ${BASE_DEST}db_backup/report/

	echo -e "\n\n" 
	echo "starting backup - binary core storage /shared" >> ${LOG}
	${RSYNC_COMMAND} -vaz /shared/binary ${BASE_DEST}binary

	#record the completion time
	echo -e "\n\n" 
	ssh ${BACKUP_CONNECT} 'touch backup_end' 
	echo "Backup completed" 
}

REDIRECT_DB="10.100.109.24"
REPORT_DB="10.100.109.22"
DB_BACKUP="/shared/db_backup"
BACKUP_TMP="/var/tmp"


function redirect () {
	mv $DB_BACKUP/redirect/redirect_prod.dmp.gz $DB_BACKUP/redirect/redirect_prod_lasthour.dmp.gz
	pg_dump -h ${REDIRECT_DB} -v -Fc -f $BACKUP_TMP/redirect_prod.dmp redirect_prod
        gzip -9 $BACKUP_TMP/redirect_prod.dmp
	mv $BACKUP_TMP/redirect_prod.dmp.gz $DB_BACKUP/redirect/
}

function report () { 
	mv $DB_BACKUP/report/report_prod.dmp.gz $DB_BACKUP/report/report_prod_lasthour.dmp.gz
	pg_dump -h ${REPORT_DB} -v -Fc -f $BACKUP_TMP/report_prod.dmp report_prod
        gzip -9 $BACKUP_TMP/report_prod.dmp
	mv $BACKUP_TMP/report_prod.dmp.gz /shared/db_backup/report/
}

function wom_apps () {
	mv $DB_BACKUP/wom_apps/wom_apps_prod.dmp.gz $DB_BACKUP/wom_apps/wom_apps_prod_lasthour.dmp
	pg_dump -v -Fc -f $BACKUP_TMP/wom_apps_prod.dmp wom_apps_prod
        gzip -9 $BACKUP_TMP/wom_apps_prod.dmp
	mv $BACKUP_TMP/wom_apps_prod.dmp.gz $DB_BACKUP/wom_apps/
}

source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
export PGUSER=""
export PGPASSWORD=""
