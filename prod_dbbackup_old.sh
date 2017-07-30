#!/bin/bash
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
wom_apps_filename="wom_apps_prod_"`date +%Y%m%d_%H%M`".tgz"
redirect_filename="redirect_"`date +%Y%m%d_%H%M`".tgz"
pg_dump -c wom_apps_prod > /tmp/wom_apps_prod.sql
pg_dump -c redirect > /tmp/redirect.sql
cd /tmp
tar -czvf /shared/db_backup/wom_apps/${wom_apps_filename} wom_apps_prod.sql
tar -czvf /shared/db_backup/redirect/${redirect_filename} redirect.sql
rm wom_apps_prod.sql
rm redirect.sql
export PGUSER=""
export PGPASSWORD=""
 
