#!/bin/bash
# set -x

if [ $# != 2 ]
then
  echo "Arg 1 must be a server Name  (cpfdev, etc.....)"
  echo "Arg 2 must be a UserName (bnguyne, etc.....)"
  exit
else
  SERVER=$1
  USERNAME=$2
fi

DATA=/root/work
CREATE="create_users"
SCP="/bin/scp -rp"
RM="/bin/rm -rf"
TAR="/bin/tar"


cd $DATA
tar cvf $CREATE.tar $CREATE

for i in $SERVER
  do
   ssh $i -C "mkdir $DATA"
   scp -rp $DATA/$CREATE.tar $i:/root/work
   ssh $i -C "cd $DATA && tar xvf $CREATE.tar "
   ssh $i -C "cd $DATA/$CREATE && sh ./$CREATE.sh --new $USERNAME"
   ssh $i -C "cd && $RM $DATA/$CREATE/ $DATA/$CREATE.tar"

# 	Clean UP
done
