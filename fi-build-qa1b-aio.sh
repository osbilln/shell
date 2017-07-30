#!/bin/bash 
PATH=/usr/bin:/bin:/usr/local/bin:/usr/local/rvm/gems/ruby-2.0.0-p247/bin:
export PATH

function copy_to_cdn02 {
    find . -name *.deb | while read f; do
       if [ -e ${f} ]; then
          cp $f /data/packages/
          update-packages
       fi
        # backup the file
    done
}

function pre-packaging {
 # Backend  
    mkdir -p cloudpass/backend
    mv backend/build backend/scripts cloudpass/backend
 # Frontend 
    mkdir -p cloudpass/frontend/idm-cloudpass
    mv frontend/idm-cloudpass/target cloudpass/frontend/idm-cloudpass/
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
       sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.6 > ${f}.7
       sed -e '653 s|enabled: false|enabled: true|g' ${f}.7 > ${f}.8
       mv ${f}.8 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7
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
       sed 's/defaultCNameARecord: "app\.fluigidentity.com."/defaultCNameARecord: "qa1b\.thecloudpass\.com\."/g' ${f}.2 > ${f}.3
       sed 's/domain: "fluigidentity\.com"/domain: "thecloudpass\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z2LWCQRAL5W90L"/g' ${f}.4 > ${f}.5
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
        sed 's/couchbaseAdminPwd=.*/couchbaseAdminPwd=OyIcyM6djb02cWAaNOnr/' ${f} > ${f}.2
        sed 's/email_admin_name=.*/email_admin_name=kungwang/g' ${f}.2 > ${f}.3
        sed 's/email_admin_password=.*/email_admin_password=u5378Ey25eU153h/g' ${f}.3 > ${f}.4
        sed 's/smtp_host=.*/smtp_host=smtp\.sendgrid\.net/g' ${f}.4 > ${f}.5
        sed 's/companyDomainSuffix=\.fluigidentity\.com/companyDomainSuffix=\.thecloudpass\.com/g' ${f}.5 > ${f}.6
        sed 's/baseUrlForMetadata=https\:\/\/app\.fluigidentity\.com\/cloudpass\//baseUrlForMetadata=https\:\/\/qa1b\.thecloudpass\.com\/cloudpass\//g' ${f}.6 > ${f}.7
#        sed 's/searchUrl=.*/searchUrl=http:\/\/127\.0\.0\.1:18084/search' ${f}.7 > ${f}.8
        mv ${f}.7 $f
        rm ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 
        cp $f ${f}.local
    done
}

function qaize_keystore_properties {
    find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed -e '89 s/false/true/g' ${f} > ${f}.0
        sed -e 's|\/tmp\/logs\/|/data\/fluigidentity-logs\/|' ${f}.0 > ${f}.1
        mv ${f}.1 ${f}
        # backup the file
        cp ${f} ${f}.local
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
        sed -e 's|\/tmp\/logs\/scim|/data\/fluigidentity-logs\/rest|' ${f}.0 > ${f}.1
        sed -e '255 s/false/true/g' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
        rm -rf ${f}.0 ${f}.1
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
        sed -e 's|\/tmp\/logs\/|/data\/fluigidentity-logs\/|' ${f} > ${f}.1
        sed -e '292 s/false/true/g' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
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
        -Durl=http://buildrepo:8081/repository/totvslabs-release/
    cd -
}

function deploy_idm_common_model_to_snapshot {
    cd idm-common-model
    mvn deploy:deploy-file \
        -Dfile=target/idm-common-model-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://buildrepo:8081/repository/totvslabs-release/
    cd -
}

function deploy_saml_java_toolkit_to_snapshot {
    cd security/protocol/saml-java-toolkit
    mvn deploy:deploy-file \
        -Dfile=target/saml-java-toolkit-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://buildrepo:8081/repository/totvslabs-release/
    cd -
}

function deploy_saml_java_rest_client_to_snapshot {
    cd security/protocol/SamlRestClient/saml-java-rest-client
    mvn deploy:deploy-file \
        -Dfile=target/saml-java-rest-client-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://buildrepo:8081/repository/totvslabs-release/
    cd -
}

function deploy_saml_rest_toolkit_to_snapshot {
    cd security/protocol/saml-rest-toolkit
    mvn deploy:deploy-file \
        -Dfile=target/saml-rest-toolkit-1.0.war \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://buildrepo:8081/repository/totvslabs-release/
    cd -
}

DATE=`date '+%Y-%m-%d-%H:%M:%S' `

FI_HOME=/data/build/fluigidentity-qa1b-aio

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

    MVN=/usr/bin
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
#        echo "git clone -b $BRANCH $repo"
#         git clone -o master $repo
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
    GRAILS=/usr/local/grails/bin
    cd $FI_HOME/$BRANCH/$FRONTEND/idm-cloudpass
    echo "Build frontend"
    $GRAILS/grails clean
    $GRAILS/grails refresh-dependencies 
    $GRAILS/grails compile 
    $GRAILS/grails war
   
    ### SECURITY
    cd $FI_HOME/$BRANCH/$SECURITY/protocol
    mvn clean install -Dmaven.test.skip=true

    ### Config Files Modifications 
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
    echo "qaize rest_yml"
    qaize_rest_yml

    ### Package
     cd $FI_HOME/$BRANCH/
     echo "Pre-Packing"
     pre-packaging

    ## Make deb packing
    FPM=/usr/local/bin/fpm
    RELEASE=`echo $BRANCH | cut -d'-' -f2`
    cd $FI_HOME/$BRANCH
    $FPM -s dir -t deb -n fluigidentity-qa1b-aio -v $RELEASE cloudpass/
    echo "builds and package are done... enjoy !!!"
    copy_to_cdn02

else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
