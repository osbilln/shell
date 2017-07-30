#!/bin/bash
set -x
SERVER=$1
for i in `cat $SERVER`
  do
     echo " =============="
     echo $i
     scp -rp motd $i:/etc/
done	
