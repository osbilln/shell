#!/bin/bash
#
# Outputs the status for the FI servers and their expected ports.
# Works on Linux or Cygwin.
#
declare -A SERVER_MAP
SERVER_MAP[8080]="Tomcat1"
SERVER_MAP[8091]="Couch"
SERVER_MAP[11122]="Keyst"
SERVER_MAP[11111]="RMI"
SERVER_MAP[2099]="HornetQ"
SERVER_MAP[18084]="Search"
SERVER_MAP[18080]="ADSync"
SERVER_MAP[2099]="HornetQ"
SERVER_MAP[18090]="Rest"

isLunix=false
if [ `uname` = "Linux" ]; then
    isLinux=true
fi

for server in "${!SERVER_MAP[@]}"
do
   if [ $isLinux ]; then
       status=`netstat -apn 2>&1 | grep :$server | awk '{print $5}'`
       if [ -z "$status" ]; then
           status="Down"
       else
           status="Up"
       fi
   else
       if [ $server = 11122 ]; then
           status=`netstat -aon | grep 1:$server | awk '{print $5}'`
       else
           status=`netstat -aon | grep 0:$server | awk '{print $5}'`
       fi

       if [ -z "$status" ]; then
           status="Down"
       fi
   fi

   echo -e "${SERVER_MAP[$server]}\t${server}\\t${status}"
done
