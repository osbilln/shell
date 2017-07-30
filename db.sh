#!/bin/bash
set -x
export PGUSER="eng"
export PGPASSWORD="62894070"
#
for i in `cat db_list.txt`
 do
  echo $i
  rm -rf *OLD
  rm -rf dmo01d.tar
  dropdb $i
  done
export PGUSER=""
export PGPASSWORD=""
