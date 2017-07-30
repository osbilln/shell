#!/bin/sh
ps -ef | grep 'service_locator' | grep -v killjetty | grep -v grep | awk '{ print $2 }' | xargs kill -9 
exit 0
