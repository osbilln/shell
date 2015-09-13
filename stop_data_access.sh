#!/bin/sh
ps -ef | awk '/data_access/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
