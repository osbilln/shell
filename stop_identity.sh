#!/bin/sh
ps -ef | awk '/library/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
