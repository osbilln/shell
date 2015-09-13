#!/bin/bash 
set -x
PATH=/usr/bin:/bin:/usr/local/bin:/usr/local/rvm/gems/ruby-2.0.0-p247/bin:
export PATH

function copy_to_cdn02 {
    find . -name *.deb | while read f; do
       if [ -e ${f} ]; then
          cp $f /data/packages
          update-packages
       fi
        # backup the file
    done
}

function pre-packaging {
 # Backend  
    mkdir -p cloudpass/backend cloudpass/frontend/idm-cloudpass/target
    mv backend/build cloudpass/backend
 # Frontend 
    mv frontend/idm-cloudpass/target/cloudpass-0.1.war cloudpass/frontend/idm-cloudpass/target/

 #   rm -rf backend frontend security 
    mv data cloudpass/
}

function enable_search {
    find . -name search.yml | while read f; do
       # first enable everything, and change data folder from /tmp/.. to /data/..
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local

       sed 's/enabled: false/enabled: true/g' $f > $f.0
	sed 's/\/tmp\//\/data\//g' $f.0 > ${f}.1
       # the enabled flag in inputConfiguration section should be disabled
       sed -e '1,/^inputConfiguration/b' -e 's/enabled: true/enabled: false/g' ${f}.1 > ${f}.2
       # after timeLineConfiguration, enable again
       sed -e '1,/^timeLineConfiguration/b' -e 's/enabled: false/enabled: true/g' ${f}.2 > ${f}.3
       # everything after hornetQServerConfiguration should be disabled
       sed -e '1,/^hornetQServerConfiguration/b' -e 's/enabled: true/enabled: false/g' ${f}.3 > ${f}.4
       sed -e '27 s|"com.totvslabs.idm.service.search.analyzer.LowerCaseEnglishKeywordAnalyzer"|"com.totvslabs.idm.service.search.analyzer.LowerCaseWhiteSpacePorterStemAnalyzer"|g' ${f}.4 > ${f}.5
       sed -e '70 s|"com.totvslabs.idm.service.search.analyzer.LowerCaseEnglishKeywordAnalyzer"|"com.totvslabs.idm.service.search.analyzer.LowerCaseWhiteSpacePorterStemAnalyzer"|g' ${f}.5 > ${f}.6
       sed -e 's|reindex: true|reindex: false|g' ${f}.6 > ${f}.7
       sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.7 > ${f}.8
       mv ${f}.8 ${f}
       rm ${f}.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7
       cp $f ${f}.local

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
       sed 's/domain: "fluigidentity\.com"/domain: "fluigidentity\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z3B4GAQ1PEMI0D"/g' ${f}.4 > ${f}.5
       mv ${f}.5 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
       cp $f ${f}.local
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
        sed 's/companyDomainSuffix=\.fluigidentity\.com/companyDomainSuffix=\.fluigidentity\.com/g' ${f}.2 > ${f}.3
        sed 's/baseUrlForMetadata=https\:\/\/app\.fluigidentity\.com\/cloudpass\//baseUrlForMetadata=https\:\/\/qa\.fluigidentity\.com\/cloudpass\//g' ${f}.3 > ${f}.4
        mv ${f}.4 $f
        rm ${f}.1 ${f}.2 ${f}.3
        cp $f ${f}.local
    done
}

function qaize_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f} > ${f}.1
        # backup the file
        mv ${f}.1 $f
        cp $f ${f}.local
    done
}

function qaize_rest_yml {
        find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/g' ${f} >  ${f}.0
        sed 's/fluigIdentityServerUrl:.* /fluigIdentityServerUrl: https\:\/\/qa\.fluigidentity\.com/g' ${f}.0 > ${f}.1
        sed 's/\/tmp/\/data/g' ${f}.1 >${f}.2
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.2 > ${f}.3
        mv ${f}.3 $f
        rm -rf ${f}.0 ${f}.1  ${f}.2
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
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed 's/\/tmp/\/data/g' ${f} >${f}.1
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.1 > ${f}.2
        mv ${f}.2 $f
        rm -rf ${f}.1
        # backup the file
        cp $f ${f}.local
    done
}

function deploy_rest_client_to_snapshot {
    cd service/rest-client
    mvn deploy:deploy-file \
        -Dfile=target/rest-client-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://10.165.4.66:8580/repository/totvslabs-release/
    cd -
}

function deploy_idm_common_model_to_snapshot {
    cd idm-common-model
    mvn deploy:deploy-file \
        -Dfile=target/idm-common-model-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://10.165.4.66:8580/repository/totvslabs-release/
    cd -
}

function deploy_saml_java_toolkit_to_snapshot {
    cd security/protocol/saml-java-toolkit
    mvn deploy:deploy-file \
        -Dfile=target/saml-java-toolkit-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://10.165.4.66:8580/repository/totvslabs-release/
    cd -
}

function deploy_saml_java_rest_client_to_snapshot {
    cd security/protocol/SamlRestClient/saml-java-rest-client
    mvn deploy:deploy-file \
        -Dfile=target/saml-java-rest-client-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://10.165.4.66:8580/repository/totvslabs-release/
    cd -
}

function deploy_saml_rest_toolkit_to_snapshot {
    cd security/protocol/saml-rest-toolkit
    mvn deploy:deploy-file \
        -Dfile=target/saml-rest-toolkit-1.0.war \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://10.165.4.66:8580/repository/totvslabs-release/
    cd -
}

DATE=`date '+%Y-%m-%d-%H:%M:%S' `

FI_HOME=/data/build/fluigidentity-qa-aio

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
    GIT_SECURITY=git@github.com:TOTVS/${SECURITY}.git

 
    # clone repos 
    cd $FI_HOME/
    mkdir $BRANCH && cd $BRANCH 
    for repo in $GIT_SECURITY $GIT_DATA $GIT_BACKEND $GIT_FRONTEND $GIT_TEST; do
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
    JAVA_HOME=/opt/jdk
    GRAILS="/usr/local/grails/bin"
    cd $FI_HOME/$BRANCH/$FRONTEND/idm-cloudpass
    echo "Build frontend"
    $GRAILS/grails clean
    $GRAILS/grails refresh-dependencies 
    $GRAILS/grails compile 
    $GRAILS/grails war
   
    ### Config Files Modifications 
    cd $FI_HOME/$BRANCH/$BACKEND
    echo "qaize keystore.server.properties"
    qaize_keystore_properties
    echo "enable search"
    enable_search
    echo "qaize server.properties"
    qaize_server_properties
    echo "qaize hornetQ server"
    qaize_hornetq
    echo "qaize adsync"
    qaize_adsync    
    echo "enable rest"
    qaize_rest_yml
    echo "enable aws"
    enable_aws

    ### Deploy REST client to repo
#    echo " Deploy Rest client to repo" 
#    deploy_rest_client_to_snapshot
#    echo " Deploy idm common to repo" 
#    deploy_idm_common_model_to_snapshot
#    echo " Java toolkit to repo" 

    ### Deploy SAML to repo
#    cd $FI_HOME/$BRANCH 
#    deploy_saml_java_toolkit_to_snapshot
#    echo " Java rest Client to repo" 
#    deploy_saml_java_rest_client_to_snapshot
#    echo " saml rest Client to repo" 
#    deploy_saml_rest_toolkit_to_snapshot

    ### Package
    cd $FI_HOME/$BRANCH/
    echo "Pre-Packing"
    pre-packaging

    ## Make deb packing
    FPM=/usr/local/bin/fpm
    RELEASE=`echo $branch | cut -d'-' -f2`
    cd $FI_HOME/$BRANCH
    $FPM -s dir -t deb -n fluigidentity-qa-aio -v $RELEASE cloudpass/
    echo "builds and package are done... enjoy !!!"
    echo "Sync to local REPO"
    copy_to_cdn02

else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
