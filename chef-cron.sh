#!/bin/bash
# Will start within 10 min of being called
sleep $(($RANDOM%600))
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"

if [ ! -f "/etc/chef/disabled" ]; then
    chef-client -L /var/log/chef/client.log -l info
fi
