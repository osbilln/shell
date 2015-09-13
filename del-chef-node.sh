#!/bin/bash
# 
# Invoke this script with several arguments, such as "one two three" ...

E_BADARGS=85

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` chef-node-IP or chef-node-NAME."
  exit $E_BADARGS
fi

echo
index=1          # Initialize count.

echo "Listing Chef-Node-IP or Name with \"\$@\":"
for arg in "$@"
 do
  echo "Arg #$index = $arg"
  let "index+=1"
#  CHEF-NODE-NAME=`knife node list | grep $arg`
  knife node delete $arg -y
  knife client delete $arg -y

 done             # $@ sees arguments as separate words.
