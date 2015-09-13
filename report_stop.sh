#!/bin/sh
ps -ef | grep 'report' | grep -v killjetty | grep -v grep | awk '{ print $2 }' | xargs kill -9 
exit 0
