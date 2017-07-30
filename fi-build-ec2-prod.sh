#!/bin/bash -e
# set -x
function pre-packaging {
 # Backend  
    mkdir -p cloudpass/backend
    mv backend/build backend/bin backend/UpgradeScripts cloudpass/backend
 # Frontend 
    mkdir -p cloudpass/frontend/idm-cloudpass
    mv frontend/idm-cloudpass/target cloudpass/frontend/idm-cloudpass/
    rm -rf backend frontend security
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
       sed 's/enabled: false/enabled: true/g' ${f}.1 > $f
       rm ${f}.1
    done
}

function productionize_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/couchbaseServerUrls=.*/couchbaseServerUrls=10\.29\.183\.142:8091;10\.143\.179\.205:8091;10\.60\.85\.99:8091/' $f > ${f}.1
        sed 's/couchbaseAdminPwd=.*/couchbaseAdminPwd=ZktwGaEhqbsAJHlAqiQP/' ${f}.1 > ${f}.2
        sed 's/cloudpassBucketPwd=.*/cloudpassBucketPwd=Lp6656MC461rn0V/' ${f}.2 > ${f}.3
        sed 's/keyStoreServer=.*/keyStoreServer=10\.169\.2\.26/' ${f}.3 > ${f}.4
        sed 's/email_admin_name=.*/email_admin_name=kungwang/g' ${f}.4 > ${f}.5
        sed 's/email_admin_password=.*/email_admin_password=u5378Ey25eU153h/g' ${f}.5 > ${f}.6
        sed 's/smtp_host=.*/smtp_host=smtp\.sendgrid\.net/g' ${f}.6 > ${f}.7
        sed 's/searchUrl=.*/searchUrl=http:\/\/10\.232\.54\.238:18084/' ${f}.7 > ${f}.8
        mv ${f}.8 $f
        rm ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7
    done
}

function productionize_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/keyStorePassword=.*/keyStorePassword=M@5}i%><!28\&3)v/g' $f > ${f}.1
        mv ${f}.1 $f
    done
}

function productionize_keystore_yml {
	find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/address: \"127.0.0.1\"/address: \"10\.169\.2\.26\"/g' $f > ${f}.1
        sed 's/remote: \"127.0.0.1\"/remote: \"10\.141\.141\.217\"/g' $f.1 > ${f}.2
	sed 's/keyStorePassword: "totvslabs"/keyStorePassword: "M@5}i%><!28&3)v"/g' $f.2 > ${f}.3
        mv ${f}.3 $f
        rm ${f}.1 ${f}.2
    done
}

function productionize_hornetq {
    find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/java\.naming\.provider\.url=.*/java\.naming\.provider\.url=jnp:\/\/10\.232\.54\.238:2099/' $f > ${f}.1
        mv ${f}.1 ${f}
    done
}

function productionize_adsync {
    find . -name adsync.yml | while read f; do
        sed 's/providerUrl:.*/providerUrl: jnp:\/\/10\.232\.54\.238:2099/' $f > ${f}.local
    done
}


DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/disk0/fluigidentity-ec2-prod

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
##    
    BACKEND=backend
    FRONTEND=frontend
    SECURITY=security
    DATA=data
##
    GIT_BACKEND=git@github.com:TOTVS/${BACKEND}.git
    GIT_FRONTEND=git@github.com:TOTVS/${FRONTEND}.git
    GIT_FRONTEND=git@github.com:TOTVS/${DATA}.git

##     GIT_SECURITY=git@github.com:TOTVS/${SECURITY}.git
   
    # clone repos 
    cd $FI_HOME
    mkdir $BRANCH && cd $BRANCH 
    for repo in $GIT_SECURITY $GIT_BACKEND $GIT_FRONTEND; do
        echo "git clone -b $BRANCH $repo"
        git clone -b $BRANCH $repo
    done 
    cd $FI_HOME/

    ###
    rm -f latest
    ln -s $BRANCH latest

    ## mvn clean install -Dmaven.test.skip=true -U; mvn clean package -Dmaven.test.skip=true -Pall-jars -U
    
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
    
    ### SAML
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
    echo "productionize server.properties"
    productionize_server_properties
    echo "productionize keystore.server.properties"
    productionize_keystore_properties
    echo "productionize keystore.yml"
    productionize_keystore_yml
    echo "productionize hornetQ server"
    productionize_hornetq
    echo "productionize adsync"
    productionize_adsync

    cd $FI_HOME/$BRANCH
    echo "productionize packaging"
    pre-packaging

 # make package
    cd $FI_HOME/$BRANCH 
    
    IDENTITY=`echo $BRANCH | cut -d'-' -f1`
    RELEASE=`echo $BRANCH | cut -d'-' -f2`
    cd $FI_HOME/$BRANCH 
    fpm.sh fluig$IDENTITY $RELEASE .
    echo "builds are done... enjoy !!!"
#     scp -rp fluig$IDENTITY*.deb brcdn01:/data/packages/deploy/
else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
