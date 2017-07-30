#!/bin/bash
set -x 
source /home/eng/.profile
export PGUSER="eng"
export PGPASSWORD="62894070"
pg_dump -h 10.100.109.22 -v -c report_prod  > report_prod.sql
gzip report_prod.sql

export PGUSER=""
export PGPASSWORD=""

