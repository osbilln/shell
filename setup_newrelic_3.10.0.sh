#!/bin/bash
echo $1 > /usr/java/list
cat /usr/java/list | \
(
while read dashboard
do
	echo $dashboard
	rm -rf /usr/java/${dashboard}/newrelic-old
	mv /usr/java/${dashboard}/newrelic /usr/java/${dashboard}/newrelic-old
	cp -rp /usr/java/newrelic-java-3.10.0.zip /usr/java/${dashboard}/
	cd /usr/java/${dashboard}/
	unzip newrelic-java-3.10.0.zip
	cd /usr/java/${dashboard}/newrelic/
	pwd
	sed -i "30 s/.*  app_name: My Application.*/  app_name: ${dashboard} /" /usr/java/${dashboard}/newrelic/newrelic.yml
	java -jar newrelic.jar install
done
)
