#!/bin/bash

NODE=$1

ssh $NODE -C "apt-get install mongodb-server mongodb -i "
ssh $NODE -C " apt-get install python-pymongo python-bson python-gridfs python-pymongo-doc -y "
ssh $NODE -C "ufw allow in on eth1 to any port 27017"
ssh $NODE -C "service mongodb restart"
# ssh $NODE -C "mongo"
# ssh $NODE -C "user protools;
# ssh $NODE -C "db.addUser("cpf_spt", "sunshine");
