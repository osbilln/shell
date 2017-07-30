#!/bin/bash
#
# This script removes and rotates logs files in various directories on our production server
#
TODAY=`date "+%F"`
DAY=`date "+%u"`

#keep 14 days of credit check logs
find /var/log/tools/credit_check_update -type f  -mtime +14 -exec rm {} \;

#clear out binlogs on dev
#find /var/lib/mysqllogs -type f -mtime +7 -exec rm {} \;

#keep 28 days of php_errors log
cp -f /home/spt/php_errors.log /home/spt/php_errors.log.$TODAY
echo "" > /home/spt/php_errors.log
find /home/spt -name "php_errors.log.*" -mtime +28 -exec rm {} \; 

#keep 28 days of CPF_messages.log
cp -f /home/spt/current_app/logs/site/CPF_messages.log /home/spt/current_app/logs/site/CPF_messages.log.$TODAY;
echo "" > /home/spt/current_app/logs/site/CPF_messages.log;
find /home/spt/current_app/logs/site -type f -mtime +28 -exec rm {} \; 


    
