#!/bin/bash


dbs=("dmiplatform" "dmiplatform_bonita_core" "dmiplatform_bonita_history" "pncprod" "salesdemo")

## now loop through the above array
for i in "${dbs[@]}"
do
   echo "dump $i"
   ./db_proc_dump.sh $i localhost root n3admin /mysqltmp/dumps naehas-operations/backups/db5
   # or do whatever with individual element of the array
done