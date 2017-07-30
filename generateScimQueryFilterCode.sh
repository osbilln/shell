echo "generate parser code when testing are done"

rm -Rf *.class
rm -Rf *.java
java -jar /usr/local/lib/antlr-4.0-complete.jar -package com.totvslabs.idm.rest.parser ScimQueryFilter.g4
if [ $? -eq 0 ]; then
    javac *.java
    echo "success"
fi
