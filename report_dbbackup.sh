#!/bin/bash
set -x 
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
mv /shared/db_backup/report/report_prod.dmp /shared/db_backup/report/report_prod_lasthour_backup.dmp
pg_dump -h 10.100.109.22 -v -Fc -f /var/tmp/report_prod.dmp report_prod
mv /var/tmp/report_prod.dmp /shared/db_backup/report/report_prod.dmp 
export PGUSER=""
export PGPASSWORD=""

