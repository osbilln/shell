cd ..
mvn clean -Dmaven.test.skip=true -Dmaven.compiler.source=1.7 -Dmaven.compiler.target=1.7 package -Pminimal-jars
cd build