#!/bin/bash

set -e
set -x

unset HISTFILE

(cat <<EOM
# note that these rms are not secure. That is OK, this is a private AMI
# and there is no sensitive data
# see http://alestic.com/2011/06/ec2-ami-security for an alternative approach
set -x
rm -f /root/.bash_history /home/fluig/.bash_history $HOME/.bash_history
find / -name authorized_keys -exec rm -f {} \;
rm -f ~root/.gemrc ~fluig/.gemrc
rm -rf ~/.gem /tmp/rubygems*
#rm -f /var/cache/apt/archives/*deb
rm -f /etc/sv/chef-client/log/main/current /var/log/chef/client.log
# no need for getty
# rm -fr  /etc/sv/getty-*
EOM
) | sudo bash
