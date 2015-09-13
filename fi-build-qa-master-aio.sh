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

function enable_search {
    find . -name search.yml | while read f; do
       # first enable everything, and change data folder from /tmp/.. to /data/..
       sed 's/enabled: false/enabled: true/g' $f | sed 's/\/tmp\//\/data\//g' > ${f}.1
       # the enabled flag in inputConfiguration section should be disabled
       sed -e '1,/^inputConfiguration/b' -e 's/enabled: true/enabled: false/;' ${f}.1 > ${f}.2
       # after timeLineConfiguration, enable again
       sed -e '1,/^timeLineConfiguration/b' -e 's/enabled: false/enabled: true/;' ${f}.2 > ${f}.3
       # everything after hornetQServerConfiguration should be disabled
       sed -e '1,/^hornetQServerConfiguration/b' -e 's/enabled: true/enabled: false/g' ${f}.3 > ${f}.local
       rm ${f}.1
       rm ${f}.2
       rm ${f}.3
    done
}

function enable_aws {
    find . -name aws.yml | while read f; do 
       # if there is a backup file, restore it
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local
       sed 's/ttl:.*/ttl: 60/g' $f > ${f}.1
       sed 's/enabled: false/enabled: true/g' ${f}.1 > ${f}.2
       sed 's/defaultCNameARecord: "app\.fluigidentity.com."/defaultCNameARecord: "qa\.fluigidentity\.com\."/g' ${f}.2 > ${f}.3
       mv ${f}.3 ${f}
       rm ${f}.1 ${f}.2 
    done
}

function qaize_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/couchbaseAdminPwd=.*/couchbaseAdminPwd=OyIcyM6djb02cWAaNOnr/' ${f} > ${f}.1
        sed 's/cloudpassBucketPwd=.*/cloudpassBucketPwd=password/' ${f}.1 > ${f}.2
        sed 's/email_admin_name=.*/email_admin_name=kungwang/g' ${f}.2 > ${f}.3
        sed 's/email_admin_password=.*/email_admin_password=u5378Ey25eU153h/g' ${f}.3 > ${f}.4
        sed 's/smtp_host=.*/smtp_host=smtp\.sendgrid\.net/g' ${f}.4 > ${f}.5
        mv ${f}.5 $f
        rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
    done
}

function qaize_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
    done
}

function qaize_hornetq {
    find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
    done
}

function qaize_adsync {
    find . -name adsync.yml | while read f; do
        echo "No need to change"
    done
}


DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/disk0/fluigidentity-master-aio

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
    for repo in $GIT_DATA $GIT_BACKEND $GIT_FRONTEND; do
        echo "git clone -b $BRANCH $repo"
        git clone -b $BRANCH $repo
    done 
    cd $FI_HOME/
    ###
    rm -f latest
    ln -s $BRANCH latest

    cd $FI_HOME/latest
 
    ### BUILD BACKEND FIRST
    echo "Build all jar files,"
    cd $FI_HOME/$BRANCH/$BACKEND
    mvn clean install -Dmaven.test.skip=true 
    mvn clean package -Dmaven.test.skip=true -Pall-jars
    
    ### BUILD Upgrade DB Script
    echo " Build upgrade DB script "
    cd $FI_HOME/$BRANCH/$BACKEND/UpgradeScripts
    mvn clean install

    ### GRAILS
    cd $FI_HOME/$BRANCH/$FRONTEND/idm-cloudpass
    echo "Build frontend"
    grails clean
    grails refresh-dependencies 
    grails compile 
    grails war
    
    ### BUILD SAML
    # cd $FI_HOME/$BRANCH/$SECURITY/protocol/saml/
    # git pull
    # sudo mvn clean install -Dmaven.test.skip=true
    # cd $FI_HOME/ 
 # modify those files again as it had been overwritten by the backend mvn build
    cd $FI_HOME/$BRANCH/$BACKEND
    echo "enable search"
    enable_search
    echo "enable aws"
    enable_aws
    echo "qaize server.properties"
    qaize_server_properties
    echo "qaize keystore.server.properties"
    qaize_keystore_properties
    echo "qaize hornetQ server"
    qaize_hornetq
    echo "qaize adsync"
    qaize_adsync    
#    cd $FI_HOME/$BRANCH
#    echo " pre-packaging "
#    pre-packaging

 # packing now
#    IDENTITY=$BRANCH
#    RELEASE=1.1.3
#   rm -rf backend frontend security
#    sleep 2
#   fpm.sh fluigidentity-$IDENTITY $RELEASE .

#    echo "builds are done... enjoy !!!"

else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
