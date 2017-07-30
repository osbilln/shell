#!/bin/bash
set -x 
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
mv /shared/db_backup/wom_apps/wom_apps_prod.dmp /shared/db_backup/wom_apps/wom_apps_prod_lasthour_backup.dmp
pg_dump -v -Fc -f /var/tmp/wom_apps_prod.dmp wom_apps_prod
mv /var/tmp/wom_apps_prod.dmp /shared/db_backup/wom_apps/wom_apps_prod.dmp
export PGUSER=""
export PGPASSWORD=""
 
