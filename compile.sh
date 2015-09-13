echo "compile grammer for testing only"

rm -Rf *.class
rm -Rf TLQ*.java
java -jar /usr/local/lib/antlr-4.0-complete.jar TLQ.g4
if [ $? -eq 0 ]; then
    javac TLQ*.java
    echo "success"
fi
