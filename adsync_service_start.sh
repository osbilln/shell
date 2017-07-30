export JAVA_OPTS="-Xms1024M -Xmx2048M"

if [ -e ../config/adsync.yml.local ]; then
  java $JAVA_OPTS -jar ../dist/ADSync.jar server ../config/adsync.yml.local
else
  java $JAVA_OPTS -jar ../dist/ADSync.jar server ../config/adsync.yml
fi
