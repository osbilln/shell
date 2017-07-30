#!/bin/bash
set -x 
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
pg_dump -h 10.100.109.24 -c redirect_prod  > redirect_prod.sql
gzip redirect_prod.sql
export PGUSER=""
export PGPASSWORD=""
 
