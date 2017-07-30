#!/bin/bash
ps -ef | grep -o "catalina.home=/usr/java/[a-zA-Z0-9]*-dashboard " | sed 's/catalina.home=\/usr\/java\///g' | sort > ~/running-dashboard.txt

cat ~/running-dashboard.txt | \
(
while read dashboard
do
        echo $dashboard
        cd /usr/java/${dashboard}/bin/
        ./shutdown.sh; sleep 30; ./startup.sh
done
)
