#!/bin/bash 
# set -x
PATH=/usr/bin:/bin:/usr/local/bin:/usr/local/rvm/gems/ruby-2.0.0-p247/bin:
export PATH

function synctoec2 {
    KEY=/root/.ssh/CloudpassServers.pem
    EC2_REPO_SERVER=repo.fluigidentity.com
    WWW="/var/www/packages"
    find . -name *.deb | while read f; do
       if [ -e ${f} ]; then
	ssh -i $KEY ubuntu@$EC2_REPO_SERVER -C " sudo rm -rf /tmp/fluig*  "
	scp -r -i $KEY ${f} ubuntu@$EC2_REPO_SERVER:/tmp
	ssh -i $KEY ubuntu@$EC2_REPO_SERVER -C " cd /tmp/ && sudo mv ${f} $WWW/ "
	ssh -i $KEY ubuntu@$EC2_REPO_SERVER -C " sudo update-packages "
       fi
        # backup the file
    done
}

function pre-packaging {
 # Backend  
    mkdir -p cloudpass/backend
    mv backend/build backend/bin backend/scripts cloudpass/backend
 # Frontend 
    mkdir -p cloudpass/frontend/idm-cloudpass
    mv frontend/idm-cloudpass/target cloudpass/frontend/idm-cloudpass/
    rm -rf backend frontend security
    mv data test cloudpass/
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
       sed 's/defaultCNameARecord: "app\.fluigidentity.com."/defaultCNameARecord: "qa1d\.thecloudpass\.com\."/g' ${f}.2 > ${f}.3
       sed 's/domain: "fluigidentity\.com"/domain: "thecloudpass\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z2LWCQRAL5W90L"/g' ${f}.4 > ${f}.5
       mv ${f}.5 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
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
        sed 's/companyDomainSuffix=\.fluigidentity\.com/companyDomainSuffix=\.thecloudpass\.com/g' ${f}.5 > ${f}.6
        sed 's/baseUrlForMetadata=https\:\/\/app\.fluigidentity\.com\/cloudpass\//baseUrlForMetadata=https\:\/\/qa1d\.thecloudpass\.com\/cloudpass\//g' ${f}.6 > ${f}.7
        mv ${f}.7 $f
        rm ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.6
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


DATE=`date '+%Y-%m-%d-%H:%M:%S' `

FI_HOME=/disk0/fluigidentity-qa1d-aio

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

    MVN=/usr/local/maven/bin
    BACKEND=backend
    FRONTEND=frontend
    SECURITY=security
    DATA=data
    TEST=test
    GIT_BACKEND=git@github.com:TOTVS/${BACKEND}.git
    GIT_FRONTEND=git@github.com:TOTVS/${FRONTEND}.git
    GIT_DATA=git@github.com:TOTVS/${DATA}.git
    GIT_TEST=git@github.com:TOTVS/${TEST}.git
   
    # clone repos 
    cd $FI_HOME/
    mkdir $BRANCH && cd $BRANCH 
    for repo in $GIT_DATA $GIT_BACKEND $GIT_FRONTEND $GIT_TEST; do
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
    $MVN/mvn clean install -Dmaven.test.skip=true 
    $MVN/mvn clean package -Dmaven.test.skip=true -Pall-jars
    
    ### GRAILS
    GRAILS=/root/.gvm/grails/current/bin
    cd $FI_HOME/$BRANCH/$FRONTEND/idm-cloudpass
    echo "Build frontend"
    $GRAILS/grails clean
    $GRAILS/grails refresh-dependencies 
    $GRAILS/grails compile 
    $GRAILS/grails war
    
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

    cd $FI_HOME/$BRANCH/
    echo "Pre-Packing"
    pre-packaging

## Make deb packing
    FPM=/usr/local/rvm/gems/ruby-2.0.0-p247/bin/fpm
    RELEASE=`echo $BRANCH | cut -d'-' -f2`
    cd $FI_HOME/$BRANCH
    $FPM -s dir -t deb -n fluigidentity-qa1d-aio -v 1.1.5 cloudpass/
    echo "builds and package are done... enjoy !!!"
    echo "Sync to EC2"
    synctoec2

else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
