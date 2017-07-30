#!/bin/bash

set -x 
# Get Release from STO repository
# This script only does get war files from SVN
# Written by: Bill Nguyen
# Date:		09/01/2012
# Revsion:	1

if [ $# != 1 ]
then
  echo "Arg 1 must be a Release number: 24, 25)"
  echo "USAGE: $0 25 "
  echo "  ===================== "
  exit 1
else
  RELEASE=$1
  echo "Release: $RELEASE"
fi


PUSH_HOME=/home/engs/wars
SPRINT_HOME=$PUSH_HOME/STO/trunk/releases/sprint

PULL_RELEASE="svn up https://sequentsw.jira.com/svn/STO/trunk/releases/sprint/$RELEASE --username b.nguyen"
cd $SPRINT_HOME && $PULL_RELEASE

if [ $? -ne 0 ]
  echo " WARNINGS: Please check your SVN strings "
   exit 1
  else
  echo " Pull is successfull"
fi
