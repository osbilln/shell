#!/bin/bash
#

if [ $# = 2 ]; then
  FILE="$1" 
  TO_SERVER=$2
   scp -r $FILE root@$TO_SERVER
else
  echo -e "\n\nUsage: $0 {FILE_NAME} {SERVER_IP or NAME}"
    echo -e "ex: $0 build-envs brcdn02\n\n"

fi
