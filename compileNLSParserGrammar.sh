echo "compile grammer for testing only"

rm -Rf *.class
rm NLSBaseListener.java
rm NLSListener.java
rm NLSParser.java
rm NLSLexer.java
java -jar /usr/local/lib/antlr-4.0-complete.jar NLS.g4
if [ $? -eq 0 ]; then
    javac NLSLexer.java NLSParser.java NLSListener.java NLSBaseListener.java
    echo "success"
fi
