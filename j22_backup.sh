#!/bin/sh

#
# A simple backup script which when run on a production server (typicaly via cron) will push all of
# our data to some place you can
#

BACKUP_CONNECT='8456@usw-s008.rsync.net'
BASE_DEST=${BACKUP_CONNECT}:
RSYNC_COMMAND='/opt/local/bin/rsync'

echo "Starting backup to $BASE_DEST"
ssh ${BACKUP_CONNECT} 'touch backup_request_start'

echo "starting backup request logs"
${RSYNC_COMMAND} -vaz /opt/zeus/log/*log ${BASE_DEST}request_logs/j22/

#record the completion time
ssh ${BACKUP_CONNECT} 'touch backup_request_end'
echo "Backup completed"

${RSYNC_COMMAND} -az ${TEMP_LOG} ${BASE_DEST}backup_logs

