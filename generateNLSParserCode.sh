echo "generate parser code when testing are done"

rm -Rf *.class
rm NLSBaseListener.java
rm NLSListener.java
rm NLSParser.java
rm NLSLexer.java

if [ $# -ge 1 ]; then
    echo "java -jar /usr/local/lib/antlr-4.0-complete.jar NLS.g4"
    java -jar /usr/local/lib/antlr-4.0-complete.jar NLS.g4
else
    echo "java -jar /usr/local/lib/antlr-4.0-complete.jar -package com.totvslabs.idm.service.search.nlsparser NLS.g4"
    java -jar /usr/local/lib/antlr-4.0-complete.jar -package com.totvslabs.idm.service.search.nlsparser NLS.g4
fi

if [ $? -eq 0 ]; then
    javac NLSLexer.java NLSParser.java NLSListener.java NLSBaseListener.java
    rm *.class
    echo "success"
fi
