#!/bin/sh
ps -ef | awk '/sharing/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
