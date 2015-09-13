jarpath="../dist/ServerStart.jar"

if [ -e $jarpath ]; then
	echo "Start the rmiserver"
	java -jar -Xms512m -Xmx1512m $jarpath
else
	echo "$jarpath does not exist"
	exit 1
fi
