jarpath="../dist/UpgradeScript.jar"

if [ -e $jarpath ]; then
	echo "Script to run upgrade scripts"
	java -jar $jarpath
else
	echo "$jarpath does not exist"
	exit 1
fi