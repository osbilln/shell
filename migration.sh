#!/bin/bash


dashboard=$(ps aux | grep java | grep -v grep | grep -v slave | awk '{print $12}' | cut -d"=" -f2 | cut -d"/" -f4)
# dashboard="usbkarmaperf-dashboard"
proxyHost=$1
for i in `echo $dashboard`
  do
    . /usr/java/$i/base-dashboard.properties
    proxyHost=$1
    ./setup-haproxy $URL $PORT $proxyHost
done
