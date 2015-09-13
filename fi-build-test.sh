#!/bin/bash -e
set -x

. /usr/bin/build_envs


DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/data/build/fluigidentity-test

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
    for repo in $GIT_BACKEND ; do
        echo "git clone -b $BRANCH $repo"
        git clone -b $BRANCH $repo
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
    
    cd $FI_HOME/$BRANCH/$BACKEND
    echo "enable search"
    va_search_yml
    echo "enable aws"
    va_aws_yml
    echo "server.properties"
    va_server_properties
    echo "keystore.server.properties"
    echo "aioize keystore.yml"
    va_keystore_yml
    va_keystore_properties
    echo "hornetQ server"
    va_hornetq
    echo "adsync"
    va_adsync_yml
    echo " Rest yml file"
    va_rest_yml

    ### 
    cd $FI_HOME/$BRANCH
    echo " pre-packaging "
    va-packaging

else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
