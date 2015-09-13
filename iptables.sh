#!/bin/bash

{
if [ $# != 2 ]
then
  echo "Arg 1 must be an environment Location (rackspace, vivo, softlayer, etc.....)"
  echo "Arg 2 must be a file type "
  exit
fi

if [ -n $1 ]
 then
   ENV=$1
   echo $ENV
 else
   exit 1
fi

if [ -e $2 ]
 then
   SERVER=`cat $2`
   echo $SERVER
 else
   SERVER=$2
   echo $SERVER
fi

# NRPE= "-A INPUT -m state --state NEW -m tcp -p tcp -s $SERVER_IP --dport 5666 -j ACCEPT"
# GANGLIA="-A INPUT -m state --state NEW -m tcp -p tcp -s $SERVER_IP --dport 8649 -j ACCEPT"
# ICMP="-A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -p icmp --icmp-type 8 -s $SERVER_IP -d 0/0 -j ACCEPT"
# TOMCAT= "-A INPUT -m state --state NEW -m tcp -p tcp -s $SERVER_IP --dport 8080 -j ACCEPT"
for i in $SERVER
  do
   echo $i
#     if [ ^$i != {a,z} ]
#      then
#       exit 1
#     endif
#    ssh $i -C " cat /etc/sysconfig/iptables | sed '8 i\ $NRPE ' > /tmp/ip" 
#    ssh $i -C " /bin/cp /tmp/ip /etc/sysconfig/iptables && /bin/rm /tmp/ip" 
#    ssh $i -C " cat /etc/sysconfig/iptables | sed '8 i\ $ICMP ' > /tmp/ip"
#    ssh $i -C " /bin/cp /tmp/ip /etc/sysconfig/iptables && /bin/rm /tmp/ip" 
#    ssh $i -C " cat /etc/sysconfig/iptables | sed '8 i\ $GANGLIA' > /tmp/ip"
#    ssh $i -C " cat /etc/sysconfig/iptables | sed '8 i\ $TOMCAT' > /tmp/ip"
#    ssh $i -C " /bin/cp /tmp/ip /etc/sysconfig/iptables && /bin/rm /tmp/ip" 
#  echo " coping .... iptables.$ENV to $i " 
#    scp -rp iptables.$ENV $i:/etc/sysconfig/iptables
#    ssh $i -C "service iptables restart"
    ssh $i -C "cat /etc/sysconfig/iptables"
    echo ""
    ssh $i -C "iptables -L "
   echo " done "
   echo " =============================================== "
  done
} > rs.iptables.`date +”%d.%m.%Y”`
