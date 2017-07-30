#!/bin/sh
ps -ef | awk '/action/' && !/awk/ {print $2}' | xargs -r kill -9
exit 0
