#!/bin/bash

if [ $# -eq 1 ]; then
   NODENAME=$1
   knife node show $NODENAME 
else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 johnkaplan\n\n"

fi
