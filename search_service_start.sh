export JAVA_OPTS="-Xms1024M -Xmx2048M"

if [ -e ../config/search.yml.local ]; then
    echo "use search.yml.local"
    java $JAVA_OPTS -jar ../dist/Search.jar server ../config/search.yml.local
else
    echo "use search.yml"
    java $JAVA_OPTS -jar ../dist/Search.jar server ../config/search.yml
fi
