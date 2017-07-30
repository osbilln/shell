#jarpath="../dist/KeystoreServerStart.jar"
#if [ -e $jarpath ]; then
#	echo "Script to start the keystore server"
#	java -jar $jarpath server ../config/keystore.yml
#else
#	echo "$jarpath does not exist"
#	exit 1
#fi
export JAVA_OPTS="-Xms1024M -Xmx2048M"

if [ -e ../config/keystore.yml.local ]; then
  java $JAVA_OPTS -jar ../dist/KeystoreServerStart.jar server ../config/keystore.yml.local
else
  java $JAVA_OPTS -jar ../dist/KeystoreServerStart.jar server ../config/keystore.yml
fi
