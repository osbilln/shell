#!/bin/bash
cat /usr/java/list | \
(
while read dashboard
do
	echo $dashboard
	cd /usr/java/${dashboard}/bin/
	./shutdown.sh; sleep 30; ./startup.sh
done
)
