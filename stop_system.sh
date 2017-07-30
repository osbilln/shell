#!/bin/sh
ps -ef | awk '/system_core/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
