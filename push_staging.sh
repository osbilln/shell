#!/bin/bash
set -x

# Get Release from Wars directory 
# This script only does push new war files after pulling from SVN
# Written by: Bill Nguyen
# Date Created:         09/01/2012
# Revsion:      1


if [ $# != 1 ]
then
  echo "Arg 1 must be a Release number: 24, 25)"
  echo "USAGE: $0 25 "
  echo "  ===================== "
  exit 1
else
  RELEASE=$1
  echo "$RELEASE"
fi


RM="/bin/rm -rf"
CP="/bin/cp -rp"
TOMCAT_HOME="/opt/tomcat"

CMS=cms.war
AUTH=sequent-oauth.war
PRIVATE=sequent-api-private.war
PUBLIC=sequent-api-public.war

PUSH_HOME=/home/engs/wars
SPRINT_HOME=$PUSH_HOME/STO/trunk/releases/sprint/staging
LATEST=$SPRINT_HOME/latest
TOMCAT_PID=`ps -ef | grep $TOMCATi_HOME | grep apache | grep -v grep | awk '{ print $2 }'`

#
# Stop and push new Release
#
sudo service tomcat stop
# sleep 10
  if [ -n "$TOMCAT_PID" ]
  then
    echo "Tomcat is still running (pid: $TOMCAT_PID)"
        echo "Stoping Tomcat (pid: $TOMCAT_PID)"
        kill -9 $TOMCAT_PID
    echo "Tomcat is stopped "
  fi

for i in $CMS $AUTH $PRIVATE $PUBLIC
  do
   echo " Remving $i war file "
   cd $TOMCAT_HOME/webapps && $RM $i
   if [ $? -ne 0 ]
    then
      echo " Removing $i failed, Please check $i file "
      exit 2
   else
     echo " Removing $i file is completed"
   fi
done   

echo " Releasing Sprint $RELEASE "
echo " =========================="

for i in $CMS $AUTH $PRIVATE $PUBLIC
  do
   echo " Copying $i war file "
   cd $TOMCAT_HOME/webapps && $CP $SPRINT_HOME/$RELEASE/$i .
   if [ $? -ne 0 ]
     then
      echo " Copying $i failed, Please check $i file exists"
      exit 3
     else
     echo " Copying $i file is completed"
   fi
done  

#
# Start tomcat
#
sudo service tomcat start

TOMCAT_PID=`ps -ef | grep $TOMCAT_HOME | grep apache | grep -v grep | awk '{ print $2 }'`
if [ -n "$TOMCAT_PID" ]
  then
    echo "Tomcat is running (pid: $TOMCAT_PID)"
    exit 0
  else
    echo "Tomcat is not running (pid: $TOMCAT_PID)"
    exit 4
  fi
# 
