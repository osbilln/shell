#!/bin/bash
# https://54.205.158.194/cloudpass/asset/image/company/small/0/default.png

# /opt/chef/embedded/bin/ruby /usr/bin/chef-client -l debug -d -P /var/run/chef/client.pid -L /var/log/chef/client.log -c /etc/chef/client.rb -i 600 -s 5

if [ $# -eq 2 ]; then
   NODENAME=$1
   RUNLIST=$2
   knife node run_list add $NODENAME "role[$RUNLIST]"
else

    echo -e "\n\nUsage: $0 {Client name} {Run List}"
    echo -e "ex: $0 jt5r5o1a752oi8ly1401496473029.yahoo.com fi-aio-test \n\n"

fi
