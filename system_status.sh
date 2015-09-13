#!/bin/bash
#
# Outputs the status for the FI servers and their expected ports.
# Works on Linux or Cygwin.
#
#declare -A SERVER_MAP
SERVER_MAP[8080]="Tomcat1"
SERVER_MAP[8091]="Couch"
SERVER_MAP[11122]="Keyst"
SERVER_MAP[11111]="RMI"
SERVER_MAP[2099]="HornetQ"
SERVER_MAP[18084]="Search"
SERVER_MAP[7475]="Neo4J"
SERVER_MAP[7474]="Neo4J2"
SERVER_MAP[18080]="ADSync"
SERVER_MAP[2099]="HornetQ"
SERVER_MAP[18090]="Rest"

lsof -h >& /dev/null
if [[  $? == 0 ]]; then
   useLsof=1
fi


for server in "${!SERVER_MAP[@]}"
do
   if [[ -n "$useLsof" ]]; then
       pid=`lsof -t -i :$server`
       if [ -z "$pid" ]; then
           pid="Down"
       fi
   else
       if [ $server = 11122 -o $server = 2099 ]; then
           pid=`netstat -aon | grep 1:$server | awk '{print $5}'`
       else
           pid=`netstat -aon | grep LISTENING | grep 0:$server | awk '{print $5}'`
       fi

       if [ -z "$pid" ]; then
           pid="Down"
       fi
   fi

   echo -e "${SERVER_MAP[$server]}\t${server}\\t${pid}"
done
