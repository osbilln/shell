#!/bin/bash
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
mv /shared/db_backup/wom_apps/wom_apps_prod.tgz /shared/db_backup/wom_apps/wom_apps_prod_lasthour_backup.tgz
pg_dump -c wom_apps_prod > /home/eng/wom_apps_prod.sql
cd /home/eng
gtar -czvf /shared/db_backup/wom_apps/wom_apps_prod.tgz wom_apps_prod.sql
rm wom_apps_prod.sql
export PGUSER=""
export PGPASSWORD=""
