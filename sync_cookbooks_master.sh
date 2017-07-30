#!/bin/bash
#

if [ $# = 1 ]; then
  COOKBOOK_NAME="$1"
  TO_SERVER="mv-fi-build-01"
  COOKBOOK_DIR="/data/chefrepo/cookbooks"
   scp -r $COOKBOOK_NAME root@$TO_SERVER:$COOKBOOK_DIR/
else
  echo -e "\n\nUsage: $0 {fi-va-default} "
    echo -e "ex: $0 cookbook_name \n\n"

fi
