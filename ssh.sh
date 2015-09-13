#!/bin/bash

SERVERS=$1
for i in `cat $SERVERS`
  do
   cat id_rsa.linux | ssh $i 'cd .ssh; cat >> authorized_keys; chmod 600 authorized_keys'
   scp -rp sshd_config $i:/etc/sshd
   ssh $i -C "service sshd restart"
  done
