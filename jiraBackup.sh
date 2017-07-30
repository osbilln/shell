#!/bin/bash
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
mv /home/eng/backups/jira.tgz /home/eng/backups/jira_yesterday.tgz
mkdir /tmp/jira
pg_dump -c fisheye > /tmp/jira/fisheye.sql
pg_dump -c fisheyejr > /tmp/jira/fisheyejr.sql
pg_dump -c jira41 > /tmp/jira/jira41.sql
gtar -zcf /tmp/jira/opt.jira.tgz /opt/jira
gtar -zcf /home/eng/backups/jira.tgz /tmp/jira
rm -rf /tmp/jira
export PGUSER=""
export PGPASSWORD=""
scp -r -i /home/eng/.ssh/rsync_id_rsa /home/eng/backups 8456@usw-s008.rsync.net:jira
 
