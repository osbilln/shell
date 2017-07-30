#!/bin/bash
SERVERS=$1
for i in `cat $SERVERS`
  do
# disable ypbind
    ssh $i -C "service ypbind stop"
    ssh $i -C "chkconfig ypbind off"
    ssh $i -C "mkdir /mnt/shared"
    ssh $i -C "cd / && ln -s /mnt/shared /shared"
    scp -rp auto.master $i:/etc/auto.master
    scp -rp auto.shared $i:/etc/auto.shared
    ssh $i -C "chkconfig autofs on"
    ssh $i -C "service autofs stop"
    ssh $i -C "service autofs start"
   sleep 10
# create basic USERS
    ssh $i -C "/shared/util/create_users/create_users.sh --new billn"
    ssh $i -C "/shared/util/create_users/create_users.sh --new dvarma"
    ssh $i -C "/shared/util/create_users/create_users.sh --new eng"
# create GROUPS
    ssh $i -C "groupadd eng"
    ssh $i -C "groupmod -g 1002 eng"
    ssh $i -C "groupadd dev"
    ssh $i -C "groupmod -g 1006 dev"
    ssh $i -C "usermod -u 500 -g 1006 billn"
    ssh $i -C "usermod -u 1001 -g 1006 dvarma"
    ssh $i -C "usermod -u 1002 -g 1002 eng"
    scp -rp /home/billn/. $i:/home/billn/.
    scp -rp /home/eng/. $i:/home/eng/.
    scp -rp /home/dvarma/. $i:/home/dvarma/.
    ssh $i -C "chown -R billn:dev /home/billn"
    ssh $i -C "chown -R dvarma:dev /home/dvarma"
    ssh $i -C "chown -R eng:eng /home/eng"
done
