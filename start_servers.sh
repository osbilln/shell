#!/bin/bash

#
# Outputs the status for the FI servers and their expected ports.
# Works on Linux or Cygwin.
#
# SERVER_MAP[8091]="Couch"
declare -A SERVER_MAP
SERVER_MAP[11122]="keystore"
SERVER_MAP[18084]="search"
SERVER_MAP[18090]="rest"
SERVER_MAP[11111]="rmi"
SERVER_MAP[18080]="adsync"
SERVER_MAP[8080]="tomcat7"
SERVER_MAP[443]="apache2"

isLunix=false
if [ `uname` = "Linux" ]; then
    isLinux=true
fi

for server in "${!SERVER_MAP[@]}"
do
   if [ $isLinux ]; then
       status=`netstat -apn 2>&1 | grep :$server | awk '{print $7}' | cut -d"/" -f1`
       if [ -z "$status" ]; then
           status="Down"
           service ${SERVER_MAP[$server]} start 
           status="Now is UP"
           echo -e "${SERVER_MAP[$server]}\t${server}\\t${status}"
           sleep 5
       else
           status="UP"
           echo -e "${SERVER_MAP[$server]}\t${server}\\t${status}"
       fi
   fi

done
