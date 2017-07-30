#!/bin/sh
ps -ef | awk '/tomcat/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
