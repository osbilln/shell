#!/bin/bash -e
set -x

function pre-packaging {
 # Backend  
    mkdir -p cloudpass/backend
    mv backend/build backend/bin backend/UpgradeScripts cloudpass/backend
 # Frontend 
    mkdir -p cloudpass/frontend/idm-cloudpass
    mv frontend/idm-cloudpass/target cloudpass/frontend/idm-cloudpass/
    mv data cloudpass/
}


DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/disk0/fluigidentity-va-aio

if [ ! -e $FI_HOME ]; then
  mkdir -p $FI_HOME
fi
    
if [ $# -eq 1 ]; then
    
    #
    #####
    #
    #echo "Please enter the branch you want to build . 
    #echo For instance identity-1.0.5"
    #read branch
    branch=$1
    
    #if [ -n $branch ]; then
    BRANCH=$branch
    if  [ -e $FI_HOME/$BRANCH ]; then
        mv $FI_HOME/$BRANCH $FI_HOME/$BRANCH-$DATE
        echo "backup existing folder"
        echo "mv $FI_HOME/$BRANCH $FI_HOME/$BRANCH-$DATE"
    fi
    #else
    #   echo "Please enter the branch you want to build . 
    #   echo "For instance identity-1.0.5"
    #   read branch
    #fi
    
    echo " building backend, frontend and security"
    echo "Plase wait ....."
    
    BACKEND=backend
    FRONTEND=frontend
    SECURITY=security
    DATA=data

    GIT_BACKEND=git@github.com:TOTVS/${BACKEND}.git
    GIT_FRONTEND=git@github.com:TOTVS/${FRONTEND}.git
    GIT_DATA=git@github.com:TOTVS/${DATA}.git

#    GIT_SECURITY=git@github.com:TOTVS/${SECURITY}.git
   
    # clone repos 
    cd $FI_HOME/
    mkdir $BRANCH && cd $BRANCH 
    for repo in $GIT_FRONTEND; do
        echo "git clone -b $BRANCH $repo"
        git clone -b $BRANCH $repo
    done 
    cd $FI_HOME/
    ###
    rm -f latest
    ln -s $BRANCH patch
    ###
    cd $FI_HOME/patch

    ### GRAILS
    cd $FI_HOME/$BRANCH/$FRONTEND/idm-cloudpass
    echo "Build frontend"
    grails clean
    grails refresh-dependencies 
    grails compile 
    grails war
    
 # modify those files again as it had been overwritten by the backend mvn build
    cd $FI_HOME/$BRANCH
    echo " pre-packaging "
    pre-packaging

 # packing now
    cd $FI_HOME/latest
    IDENTITY=`echo $BRANCH | cut -d'-' -f1`
    RELEASE=`echo $BRANCH | cut -d'-' -f2`
    rm -rf backend frontend security
    sleep 2
    fpm.sh fluig$IDENTITY-va-aio $RELEASE .
#
    echo "builds are done... enjoy !!!"
#
else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
