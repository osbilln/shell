#!/bin/bash -e

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

BACKEND=/cloudpass/backend
FRONTEND=/cloudpass/frontend
SECURITY=/cloudpass/security
GIT_BACKEND=git@github.com:TOTVS/backend.git
GIT_FRONTEND=git@github.com:TOTVS/frontend.git
GIT_SECURITY=git@github.com:TOTVS/security.git


cd $FLUIG_HOME

if [ -e $BRANCH ]
  then
  exit 2
else
  mkdir $BRANCH && cd $BRANCH 
  git clone -b $BRANCH $GIT_BACKEND
  git clone -b $BRANCH $GIT_BACKEND
  git clone -b $BRANCH $GIT_BACKEND
fi

 
### BUILD BACKEND FIRST
cd $FLUIG_HOME/$BRANCH/BACKEND
mvn clean -Dmaven.test.skip=true package -Pall-jars
mvn clean install

### SAML
cd $FLUIG_HOME/$BRANCH/$SECURITY/protocol/saml/
git pull
sudo mvn clean install

### GRAILS

cd $FLUIG_HOME/$BRANCH/$FRONTEND/idm-cloudpass
grails clean
grails refresh-dependencies 
grails compile 
grails war

cd $FLUIG_HOME/ 
rm -rf latest
ln -s $BRANCH ./latest
echo "builds are done... enjoy !!!"
