#!/bin/bash
jarpath="../dist/VAPopulateScript.jar"

if [ -e $jarpath ]; then
	echo "Script to run Populate scripts"
	java -jar $jarpath
else
	echo "$jarpath does not exist"
	exit 1
fi
