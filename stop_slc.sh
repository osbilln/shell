#!/bin/sh
ps -ef | awk '/service_locator/ && !/awk/ {print $2}' | xargs -r kill -9
exit 0
