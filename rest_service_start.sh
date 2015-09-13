export JAVA_OPTS="-Xms1024M -Xmx2048M"

if [ -e ../config/rest.yml.local ]; then
  java $JAVA_OPTS -jar ../dist/rest.jar server ../config/rest.yml
else
  java $JAVA_OPTS -jar ../dist/rest.jar server ../config/rest.yml
fi
