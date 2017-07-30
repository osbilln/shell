#!/bin/bash
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
mv /shared/db_backup/report/report_prod.tgz /shared/db_backup/report/report_prod_lasthour_backup.tgz
pg_dump -c report_prod > /home/eng/report_prod.sql
cd /home/eng
gtar -czvf /shared/db_backup/report/report_prod.tgz report_prod.sql
rm report_prod.sql
export PGUSER=""
export PGPASSWORD=""
