#!/bin/sh
ps -ef | awk '/identify/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
