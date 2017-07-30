#!/bin/sh
ps -ef | awk '/data_import/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
