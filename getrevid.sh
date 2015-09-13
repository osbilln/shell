#!/bin/bash

if [ $# != 1 ]
then
  echo "Arg 1 is your SEID "
  exit
fi

if [ -n $1 ]
 then
   SEID=$1
   echo "You have entered $SEID"
 else
   exit 1
fi



REV="rev_"
SEIDDOC=`curl -X GET https://gass.
REVID=cat $SEIDDOC | cut -d"," -f2 |sed s/\"//g |awk -F":" '{print $2}'


