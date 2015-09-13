#!/bin/sh
ps -ef | grep 'advocate_tweets' | grep -v killjetty | grep -v grep | awk '{ print $2 }' | xargs kill -9 
exit 0
