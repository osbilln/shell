jarpath="../dist/SyncGlobalApps.jar"

if [ -e $jarpath ]; then
	echo "Script to sync global applications"
	java -jar $jarpath
else
	echo "$jarpath does not exist"
	exit 1
fi