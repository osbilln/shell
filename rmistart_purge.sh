jarpath="../dist/ServerStart.jar"

hostname="localhost"
if [ "$1" != "" ]; then
    hostname=$1 
fi

# clean the mysql database
#./my_sql_clean.sh 

# next clean the CB server.
#./cb_flush.sh 
	
if [ -e $jarpath ]; then
	echo "Script to start the rmiserver"
	java -jar -Xms512m -Xmx1512m $jarpath purge
else
	echo "$jarpath does not exist"
	exit 1
fi
