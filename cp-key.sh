#!/bin/bash

BILLKEY="/Users/billnguyen/.ssh/id_rsa.pub"
for i in `cat br-server-list`
 do
  echo "============================="
  echo $i
  ssh -l root $i -C  " ssh-keygen "
  scp -rp ~billnguyen/.ssh/id_rsa.pub root@$i:.ssh/authorized_keys
  echo "============================="
done
