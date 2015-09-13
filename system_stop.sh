#!/bin/bash
#
# Stops the BE processes needed to run the CP system (except for keystore).
#
#declare -A SERVER_MAP
SERVER_MAP[11111]="RMI"
SERVER_MAP[18084]="Search"
SERVER_MAP[18080]="ADSync"
SERVER_MAP[18090]="Rest"

JAR_FILES=(
"/dist/KeystoreServerStart.jar"
"/dist/Search.jar"
"/dist/rest.jar"
"/dist/ServerStart.jar"
"/dist/ADSync.jar"
)


os=`uname -a`
if [[ "$os" == *Cygwin* ]]; then
    for server in "${!SERVER_MAP[@]}"
    do
        if [[ -n "$useLsof" ]]; then
            pid=`lsof -t -i :$server`
            if [ -n "$pid" ]; then
                kill -9 $pid
            fi
        else
            pid=`netstat -aon | grep LISTENING | grep 0:$server | awk '{print $5}'`
            if [ -n "$pid" ]; then
                /bin/kill -f $pid
            fi
        fi
    
    done
else
   for jarfile in "${JAR_FILES[@]}"
   do
      pid=`ps ax | grep java | grep $jarfile | awk '{print $1}'`
      if [ -n "$pid" ]; then 
          kill -9 $pid
          if [[  $? != 0 ]]; then
              echo "Could not kill $jarfile"
              exit 1
          fi
      fi
   done
fi

exit 0


