#!/bin/bash

if [ $# -eq 2 ]; then
   NODENAME=$1
   RUNLIST=$2
   knife node run_list remove $NODENAME "role[$RUNLIST]"
else

    echo -e "\n\nUsage: $0 {CLient name} {Run List}"
    echo -e "ex: $0 jt5r5o1a752oi8ly1401496473029.yahoo.com fi-aio-test \n\n"

fi
