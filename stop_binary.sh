#!/bin/bash
ps -ef | awk '/binary/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
