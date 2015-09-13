#!/bin/bash
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
mv /shared/db_backup/redirect/redirect_prod.tgz /shared/db_backup/redirect/redirect_prod_lasthour_backup.tgz
pg_dump -c redirect_prod > /home/eng/redirect_prod.sql
cd /home/eng
gtar -czvf /shared/db_backup/redirect/redirect_prod.tgz redirect_prod.sql
rm redirect_prod.sql
export PGUSER=""
export PGPASSWORD=""
