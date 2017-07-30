#!/bin/bash

set -x

cd coxkitsperfstore

find . -name apache-tomca* -type d | while read java_tomcat
 do
	echo $java_tomcat
	if [[ -d ${java_tomcat}/newrelic-old ]]; then
		rm -rf java_tomcat}/newrelic-old
	fi

	if [[ -d ${java_tomcat}/newrelic ]]; then
		mv ${java_tomcat}/newrelic ${java_tomcat}/newrelic-old
	fi
	
	if [[ ! -f ${java_tomcat}/ ]]; then
		cp -rp /usr/java/newrelic-java-3.10.0.zip ${java_tomcat}/
	fi
	
	cd ${java_tomcat}
	unzip -o newrelic-java-3.10.0.zip
	cd newrelic
	pwd
	sed -i "30 s/.*  app_name: My Application.*/  app_name: coxkitsperfstore /" newrelic.yml
	java -jar newrelic.jar install

	cd ../bin
	./shutdown.sh
	export JAVA_HOME="/usr/java/coxkitsperfstore/assets/java/linux/jdk1.8.0_40"
	echo $JAVA_HOME
	export PATH="/usr/java/coxkitsperfstore/assets/apache-ant-1.8.2/bin":"/usr/java/coxkitsperfstore/assets/maven/apache-maven-3.0.5/bin":"/usr/java/coxkitsperfstore/assets/java/linux/jdk1.8.0_40/bin":"$PATH"
	process=`ps ax | grep coxkitsperfstore | grep -v grep | awk '{print $1}'`
	if [[ -n $process  ]]; then
		kill -9 $process
	fi
	./startup.sh
 done


