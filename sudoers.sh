#!/bin/bash


NAGIOS=/usr/local/nagios
SERVER=$*

for i in `cat $SERVER `
# for i in $SERVER
  do
   echo $i
#   ssh $i -C "cat /etc/sudoers | sed '$ i nagios ALL=(ALL) NOPASSWD:/usr/local/nagios/libexec' > /tmp/sudoers"
#   ssh $i -C "/bin/cp -rp /tmp/sudoers /etc/."
   scp sudoers $i:/etc/sudoers
  done
