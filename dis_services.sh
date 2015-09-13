#!/bin/bash
if [ $# != 1 ]
then
  echo "Arg 1 must be an environment (host list etc.....)"
  exit
else
  SERVER=$1
  echo "$SERVER"
fi


for i in `cat $SERVER`
  do 
   echo $i 
   echo 
   scp -rp dis_rservices.sh dis_services $i:
   ssh $i -C " sh dis_rservices.sh "
   ssh $i -C " chkconfig | grep 3:on "
   ssh $i -C " /bin/rm /root/dis_rservices.sh dis_services "
   ssh $i -C " reboot "
  done 

