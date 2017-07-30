#!/bin/sh
ps -ef | awk '/persistence/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
