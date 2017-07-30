#!/bin/bash

cat ~/running-dashboard.txt | \
(
while read dashboard
do
        echo $dashboard
        cd /usr/java/${dashboard}/bin/
        ./startup.sh; sleep 10
done
)
