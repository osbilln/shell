#!/bin/bash
set -x
dashboards=$1
# Need argunents
#
for i in `cat $dashboards`
  do
   cd /usr/java/$i/bin
   ./startup.sh

 done
