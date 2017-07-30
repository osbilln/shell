#!/bin/bash
set -x 
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
mv /shared/db_backup/redirect/redirect_prod.dmp /shared/db_backup/redirect/redirect_prod_lasthour_backup.dmp
pg_dump -h 10.100.109.24 -v -Fc -f /var/tmp/redirect_prod.dmp redirect_prod
mv /var/tmp/redirect_prod.dmp /shared/db_backup/redirect/redirect_prod.dmp 
export PGUSER=""
export PGPASSWORD=""
 
