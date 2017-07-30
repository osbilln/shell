jarpath="../dist/ServerStop.jar"

if [ -e $jarpath ]; then
	echo "Script to stop the rmiserver"
	java -jar $jarpath
else
	echo "$jarpath does not exist"
	exit 1
fi