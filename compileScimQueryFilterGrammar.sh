echo "compile grammer for testing only"

rm -Rf *.class
rm -Rf *.java
java -jar /usr/local/lib/antlr-4.0-complete.jar ScimQueryFilter.g4
if [ $? -eq 0 ]; then
    javac *.java
    echo "success"
fi
