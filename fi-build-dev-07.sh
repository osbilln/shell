#!/bin/bash 
PATH=/usr/bin:/bin:/usr/local/bin:/usr/local/rvm/gems/ruby-2.0.0-p247/bin:
export PATH
set -x

. /etc/profile

DATE=`date '+%Y-%m-%d-%H:%M:%S' `

FI_HOME=/data/build/fluigidentity-groupimpl

if [ ! -e $FI_HOME ]; then
  mkdir -p $FI_HOME
fi

. /usr/bin/build_envs

if [ $# -eq 3 ]; then
    branch=$1
    
    #if [ -n $branch ]; then
    BRANCH=$branch
    if  [ -e $FI_HOME/$BRANCH ]; then
        mv $FI_HOME/$BRANCH $FI_HOME/$BRANCH-$DATE
        echo "backup existing folder"
        echo "mv $FI_HOME/$BRANCH $FI_HOME/$BRANCH-$DATE"
    fi
    
    echo " building backend, frontend and security"
    echo "Plase wait ....."

    MVN=/usr/bin
    BACKEND=backend
    FRONTEND=frontend
    DATA=data

    GIT_BACKEND=git@github.com:TOTVS/${BACKEND}.git
    GIT_FRONTEND=git@github.com:TOTVS/${FRONTEND}.git
    GIT_DATA=git@github.com:TOTVS/${DATA}.git
 
    # clone repos 
    cd $FI_HOME/
    mkdir $BRANCH && cd $BRANCH 
    if [ $2 == "master" ] ; then
      git clone -o $2 $GIT_BACKEND
    else 
      git clone -b $2 $GIT_BACKEND
    fi 

    if [ $3 == "master" ] ; then
    git clone -o $3 $GIT_FRONTEND
    else 
    git clone -b $3 $GIT_FRONTEND
    fi 
  git clone -o master $GIT_DATA
check_error
    cd $FI_HOME/

    ###
    rm -f latest
    ln -s $BRANCH latest
    cd $FI_HOME/latest
 
    ### BUILD BACKEND FIRST
    echo "Build all jar files,"
    cd $FI_HOME/$BRANCH/$BACKEND
    $MVN/mvn clean install -Dmaven.test.skip=true 
check_error
    $MVN/mvn clean package -Dmaven.test.skip=true -Pall-jars
check_error
    
    ### GRAILS
    JAVA_HOME=/opt/jdk
    GRAILS=/usr/local/grails/bin
    cd $FI_HOME/$BRANCH/$FRONTEND/idm-cloudpass
    echo "Build frontend"
    $GRAILS/grails clean
check_error
    $GRAILS/grails refresh-dependencies 
check_error
    $GRAILS/grails compile 
check_error
    $GRAILS/grails war
check_error
  

 ### modify those files again as it had been overwritten by the backend mvn build
    cd $FI_HOME/latest/$BACKEND

    echo "dev keystore.server.properties"
    dev_keystore_properties

    echo "dev keystore.yml"
    dev_keystore_yml

    echo "enable search"
    dev_search_yml

    echo " Rest yml file"
dev_ps_rest_yml

    echo "dev server.properties"
dev_ps_server_properties

    echo "dev adsync"
    dev_adsync_yml

    echo "dev hornetQ server"
    dev_hornetq

    echo "enable aws"
dev_ps_aws_yml

    ###
    cd $FI_HOME/$BRANCH
    echo " pre-packaging "
    dev_packaging

check_error
    ## Make deb packing
    FPM=/usr/local/bin/fpm
    RELEASE=`echo $BRANCH | cut -d'-' -f2`
    cd $FI_HOME/$BRANCH
    $FPM -s dir -t deb -n fluigidentity-groupimpl -v $RELEASE cloudpass/
check_error
    cd $FI_HOME/latest
    echo "builds and package are done... enjoy !!!"
    copy_to_repo

else

    echo -e "\n\nUsage: $0 {branch name} {Backend Branch} {Frontedn Branch}"
    echo -e "ex: $0 identity-1.1 identity-groupimpl master\n\n"

fi
