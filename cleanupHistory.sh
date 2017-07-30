#!/bin/bash
set -x
function clean_up() {
   scp -r bash_history $Username@${HOST}:.${HISTORY}
}

if [ $# -eq 2 ]; then
   HISTORY=bash_history
   HOST=$1
   Username=$2
   clean_up
else
    echo -e "\n\nUsage: $0 {Hostname} {username}"
    echo -e "ex: $0 devlacpo1 billn\n\n"
fi
