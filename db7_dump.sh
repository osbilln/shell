#!/bin/bash

# list of db7 databases to dump up to s3
citinew_dbs=("citinew8" "citinew8_bonita_core" "citinew8_bonita_history" "citinew_staging")
citi_dbs=("citiprod2_staging" "citiprod3" "citiprod3_bonita_core" "citiprod3_bonita_history" "citiprod3_staging") 
comcast_dbs=("comcastprod" "comcastprod_bonita_core" "comcastprod_bonita_history") # "comcastprod_staging") 
comcastmdu=("comastmduprod")
cox_dbs=("coxkitsprodstore" "coxprod" "coxprod_bonita_core" "coxprod_bonita_history" "coxprod_staging")
naehas_dbs=("naehasdemo10" "naehasdemo10_bonita_core" "naehasdemo10_bonita_history" "naehasdemo10_staging")
usbank_dbs=("usbankprod" "usbankprod_bonita_core" "usbankprod_bonita_history") # "usbankprod_staging")
wlpp_dbs=("wlpprod" "wlpprod_bonita_core" "wlpprod_bonita_history" "wlpprod_staging")

dbs=("${citinew_dbs[@]}" "${cox_dbs[@]}" "${usbank_dbs[@]}" "${comcast_dbs[@]}")

## now loop through the above array
for i in "${dbs[@]}"
do
   echo "dump $i"
   ./db_full_dump.sh $i localhost root n3admin /mysqltmp/dumps naehas-operations/backups/db7
   # or do whatever with individual element of the array
done






