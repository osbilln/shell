#!/bin/bash
#jarfile="../dist/ServerStart.jar"
jarfile=$(ls -1t ../dist/PendingAgent.jar | head -n 1)


if [ $# -eq 1 ]; then
   $agentname="$1"
   if [ -e $jarfile ]; then
	echo "Script to start the rmiserver"
	java -jar -Xms1024m -Xmx2048m $jarfile $1
   else
	echo "$jarfile does not exist"
	exit 1
   fi
else
   echo "USAGE: $0 agentname"
fi
