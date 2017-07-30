#!/bin/bash


dbs=("mysql" "dmiplatform" "dmiplatform_bonita_core" "dmiplatform_bonita_history" "pncprod" "salesdemo")

## now loop through the above array
for i in "${dbs[@]}"
do
   echo "dump $i"
   ./db_full_dump.sh $i localhost root n3admin /data2/dumps naehas-operations/backups/db8
   # or do whatever with individual element of the array
done






