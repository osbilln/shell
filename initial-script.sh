#!/bin/bash

BILLKEY="/Users/billnguyen/.ssh/id_rsa.pub"
for i in `cat br-server-list`
 do
  echo "============================="
  echo $i
  ssh $i -C "scp -rp useradd root@$i:/etc/skel/."
  ssh $i -C "useradd -m bill"
  ssh $i -C "useradd -m kung"
  ssh $i -C "scp -rp root@$i:$BILLKEY ~bill/.ssh/authorized_keys"
  ssh $i -C "chmod 400 ~bill/.ssh/authorized_keys"
  ssh bill@$i
  echo "============================="
done
