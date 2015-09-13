#!/bin/bash

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

HTTP=httpd.conf
HTTPDIR="/etc/httpd/conf"
SSL=ssl.conf
SSLDIR="/etc/httpd/conf.d"
TOMCAT=tomcat.conf

for i in $SERVER
  do
   echo $i
    scp -rp httpd.conf.$ENV $i:/etc/httpd/conf/$HTTP
    scp -rp ssl.conf.$ENV $i:/etc/httpd/conf.d/$SSL
    scp -rp tomcat.conf.$ENV $i:/etc/httpd/conf.d/$TOMCAT
   echo " done "
   echo " =============================================== "
  done
