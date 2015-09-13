#!/bin/bash
# set -x


if [ $# -eq 2 ]
 then
  ACCESS_KEY=~billnguyen/.ssh/id_rsa
  knife bootstrap $1 \
	--ssh-port 22 \
	--ssh-user billn \
	-i "$ACCESS_KEY" \
 	--sudo \
	--run-list "recipe[$2]"
else
    echo ""
    echo -e "\n\nUsage: $0 {servername} {recipe}"
    echo -e "ex: $0 qa1 haproxy\n\n"
    echo ""

fi
