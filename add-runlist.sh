#!/bin/bash
# https://54.205.158.194/cloudpass/asset/image/company/small/0/default.png

# /opt/chef/embedded/bin/ruby /usr/bin/chef-client -l debug -d -P /var/run/chef/client.pid -L /var/log/chef/client.log -c /etc/chef/client.rb -i 600 -s 5


# knife node run_list remove vicentegoetten 'role[fi-aio-deploy]'
# knife node run_list remove vicentegoetten 'recipes[fi-aio-deploy]'
# knife node run_list add vicentegoetten 'role[fi-aio-deploy]'
#   knife node run_list add $NODENAME 'role[fi-qa1b-aio-deploy]'
#   knife node run_list add $NODENAME 'role[fi-init-patch]'

if [ $# -eq 1 ]; then
   NODENAME=$1
   knife node run_list add $NODENAME 'role[fi-aio-deploy]'
else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 johnkaplan\n\n"

fi
