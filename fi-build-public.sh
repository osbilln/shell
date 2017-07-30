#!/bin/bash -e
set -x 
echo "Please enter the branch you want to build"
read branch


if [ -n $branch ]
  then
   BRANCH=$branch
   FLUIG_HOME=/disk0/fluig
  else
   exit
fi

echo "I am building backend, frontend and security"
echo "Plase wait ....."

BACKEND=backend
FRONTEND=frontend
SECURITY=security
GIT_BACKEND=git@github.com:TOTVS/backend.git
GIT_FRONTEND=git@github.com:TOTVS/frontend.git
GIT_SECURITY=git@github.com:TOTVS/security.git


cd $FLUIG_HOME

if [ ! -d $BRANCH ]
  then
  mkdir $BRANCH && cd $BRANCH  2>&1
  git clone -b $BRANCH $GIT_FRONTEND
fi

### GRAILS
cd -

cd $FLUIG_HOME/$BRANCH/$FRONTEND/idm-cloudpass
grails clean
grails refresh-dependencies 
grails compile 
grails war

cd $FLUIG_HOME/ 
echo "builds are done... enjoy !!!"
