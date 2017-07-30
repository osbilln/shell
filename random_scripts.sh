#!/bin/bash
jarpath="../dist/RandomScripts.jar"

if [ -e $jarpath ]; then
	echo "Script to download global applications"
	java -jar $jarpath
else
	echo "$jarpath does not exist"
	exit 1
fi
