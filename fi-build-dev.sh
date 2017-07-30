#!/bin/bash -e
# set -x

. /etc/profile
. /usr/bin/build_envs

DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/data/build/fluigidentity-dev-aio

if [ ! -e $FI_HOME ]; then
  mkdir -p $FI_HOME
fi
    
if [ $# -eq 1 ]; then
    
    #####
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
    GIT_SECURITY=git@github.com:TOTVS/${SECURITY}.git

#    GIT_SECURITY=git@github.com:TOTVS/${SECURITY}.git
   
    # clone repos 
    cd $FI_HOME/
    mkdir $BRANCH && cd $BRANCH 
    for repo in $GIT_DATA $GIT_BACKEND $GIT_FRONTEND; do
        echo "Pulling from master $repo"
        git clone -o master $repo
    done 
    cd $FI_HOME/
    ###
    rm -f latest
    ln -s $BRANCH latest
    ###
    cd $FI_HOME/latest
 
    ### BUILD BACKEND FIRST
    echo "Build all jar files,"
    cd $FI_HOME/$BRANCH/$BACKEND
    git branch 
    MAVEN=/usr/local/maven/bin 
    $MAVEN/mvn clean install -Dmaven.test.skip=true 
    $MAVEN/mvn clean package -Dmaven.test.skip=true -Pall-jars
 
    
    ### GRAILS
    cd $FI_HOME/$BRANCH/$FRONTEND/idm-cloudpass
    git branch 
    echo "Build frontend"
    GRAILS=/usr/local/grails/bin
    $GRAILS/grails clean
    $GRAILS/grails refresh-dependencies 
    $GRAILS/grails compile 
    $GRAILS/grails war
    
    echo "dev keystore.server.properties"
    dev_keystore_properties
    
    echo "dev keystore.yml"
    dev_keystore_yml

    echo "enable search"
    dev_search_yml
    
    echo " Rest yml file"
    dev_rest_yml

    echo "dev server.properties"
    dev_server_properties

    echo "dev adsync"
    dev_adsync_yml

    echo "dev hornetQ server"
    dev_hornetq
    
    echo "enable aws"
    dev_aws_yml
    
    ### 
    cd $FI_HOME/$BRANCH
    echo " pre-packaging "
    dev_packaging

## Make deb packing
    FPM=/usr/local/bin/fpm
    RELEASE=`echo $branch | cut -d'-' -f2`
    cd $FI_HOME/$BRANCH
    $FPM -s dir -t deb -n fluigidentity-dev-aio -v $RELEASE cloudpass/
    echo "builds and package are done... enjoy !!!"
    echo "Sync to local REPO"
    copy_to_repo

else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
