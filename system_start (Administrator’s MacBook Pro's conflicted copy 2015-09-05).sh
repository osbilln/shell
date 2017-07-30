#!/bin/bash
#
# Starts the BE processes needed to run the CP system.
#
#declare -A SERVER_MAP
SERVER_MAP[11111]="RMI"
SERVER_MAP[18084]="Search"
SERVER_MAP[18080]="ADSync"
SERVER_MAP[18090]="Rest"

function getPidForPort() {
    if [ -n "$useLsof" ]; then
        pid=`lsof -t -i :$1`
    else
       if [ $1 = 11122 ]; then
           PID=`netstat -aon | grep 1:$1 | awk '{print $5}'`
       else
           PID=`netstat -aon | grep LISTENING | grep 0:$1 | awk '{print $5}'`
       fi
    fi
    return $PID
}

LOG_DIR=$HOME/cloudpass_logs
if [[ $1 == "-help" ]]; then
    echo "Usage: systemstart.sh [purge]"
    exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
  echo "Creating log directory $LOG_DIR"
  mkdir -p $LOG_DIR
fi

#check arguments
for var in "$@"
do
    if [[ $var == -purge ]]; then
        doPurge=1
    fi
    if [[ $var == -noadsync ]]; then
        noADsync=1
    fi
done


if [[ $os = *Linux* ]]; then
    useLsof=true
fi
if [[ $os = *MacBook* ]]; then
    useLsof=true
fi


#check that everything is down
for server in "${!SERVER_MAP[@]}"
do
    getPidForPort $server
    if [ -n "$PID" ]; then
        echo -e "Error: ${SERVER_MAP[$server]} is already running at $server."
        exit 1
    fi
done

#start keystore if not running
getPidForPort 11122
if [ -z "$PID" ]; then
    echo "Start keystore"
    ./keystore_server_start.sh >$LOG_DIR/keystore_stdout.log 2>&1 &
    sleep 1
fi

echo Start search
./search_service_start.sh >$LOG_DIR/search_stdout.log 2>&1 &
sleep 2

echo Start REST
./rest_service_start.sh >$LOG_DIR/rest_stdout.log 2>&1 &
sleep 2

if [ -z "$doPurge" ]; then
   echo Start RMI
  ./rmistart.sh >$LOG_DIR/rmi_stdout.log 2>&1 &
else
   echo Start RMI with purge
  ./rmistart_purge.sh >$LOG_DIR/rmi_stdout.log 2>&1 &
fi
sleep 2

if [ -z "$noADsync" ]; then
   echo Start ADSync
  ./adsync_service_start.sh >$LOG_DIR/adsync_stdout.log 2>&1 &
fi

echo "Cloudpass servers are up."
exit 0

