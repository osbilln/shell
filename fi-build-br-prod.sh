#!/bin/bash -e
PATH=/usr/bin:/bin:/usr/local/bin:/usr/local/rvm/gems/ruby-2.0.0-p247/bin:
set -x
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=512m"

function copy_to_repo {

    WWW="/data/packages/"
    find . -name *.deb | while read f; do
       if [ -e ${f} ]; then
        cp -r ${f} $WWW/
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
       sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.6 > ${f}.7
       sed -e 's|\/tmp\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.7 > ${f}.8
       sed -e '653 s|enabled: false|enabled: true|g' ${f}.8 > ${f}.9
       sed -e 's|reindex: true|reindex: false|g' ${f}.9 > ${f}.10
       sed 's/providerUrl.*/providerUrl: "jnp:\/\/172\.20\.16\.16:2099"/' ${f}.10 > ${f}.11
       mv ${f}.11 ${f}
       rm $f.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9 ${f}.10
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
       sed 's/enabled: false/enabled: true/g' ${f}.1 > $f
       /bin/rm ${f}.1
       cp ${f} $f.local
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
        sed 's/couchbaseServerUrls=.*/couchbaseServerUrls=172\.21\.16\.11:8091;172\.21\.16\.12:8091;/' $f > ${f}.1
        sed 's/couchbaseAdminPwd=.*/couchbaseAdminPwd=ZktwGaEhqbsAJHlAqiQP/' ${f}.1 > ${f}.2
        sed 's/cloudpassBucketPwd=.*/cloudpassBucketPwd=Lp6656MC461rn0V/' ${f}.2 > ${f}.3
        sed 's/keyStoreServer=.*/keyStoreServer=172\.20\.16\.14/' ${f}.3 > ${f}.4
        ## Replace SearchURL
        sed 's/searchUrl=.*/searchUrl\=http\:\/\/172.20.16.16\:18084\/search/' ${f}.4 > ${f}.5
        sed 's/email_admin_name=.*/email_admin_name=support@fluigidentity.com/g' ${f}.5 > ${f}.6
        sed 's/email_admin_password=.*/email_admin_password=s\[78Q4-52331FE)/g' ${f}.6 > ${f}.7
        sed 's/smtp_host=.*/smtp_host=mail\.fluigidentity\.com/g' ${f}.7 > ${f}.8
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.8 >  ${f}.9
        mv ${f}.9 $f
        rm ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8
        cp ${f} $f.local
    done
}

function productionize_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp ${f} ${f}.local
        sed 's/keyStorePassword=totvslabs/keyStorePassword=M\@5\}i\%\>\<\!28\&3\)v/g' ${f} > ${f}.1
        mv ${f}.1 ${f}
        cp ${f} $f.local
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
        sed 's/listenAddress:.*/listenAddress: "172.20.16.14"/' ${f} > ${f}.1
        sed 's/address: \"127.0.0.1\"/address: \"172.20.16.14\"/g' $f.1 > ${f}.2
        sed 's/address: \"localhost\"/address: \"172.20.16.14\"/g' $f.2 > ${f}.3
        sed 's/remote: \"127.0.0.1\"/remote: \"172.20.16.20\"/g' $f.3 > ${f}.4
        sed 's/keyStorePassword: \"totvslabs\"/keyStorePassword: \"M@5}i%><!28\&3)v"/g' ${f}.4 > ${f}.5
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.5 > ${f}.6
        sed -e 's|\/tmp\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.6 > ${f}.7
        sed -e '89 s/false/true/g' ${f}.7 > ${f}.8
        mv ${f}.8 ${f}
        rm -rf ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7
        cp $f ${f}.local
    done
}

function productionize_rest_yml {
        find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/' ${f} > ${f}.0
        sed 's/fluigIdentityServerUrl:.*/fluigIdentityServerUrl: https\:\/\/app\.fluigidentity\.com/' ${f}.0 > ${f}.1
        sed 's/providerUrl.*/providerUrl: "jnp:\/\/172\.20\.16\.16:2099"/' ${f}.1 > ${f}.2
        sed -e '229 s/false/true/' ${f}.2 > ${f}.3
        sed 's/listenAddress:.*/listenAddress: "172\.20\.16\.16"/g' ${f}.3 > ${f}.4
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.4 > ${f}.5
        sed -e '255 s/false/true/g' ${f}.5 > ${f}.6
        mv ${f}.6 $f
        rm -rf ${f}.0 ${f}.1  ${f}.2 ${f}.3 ${f}.4 ${f}.5
        cp $f ${f}.local
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
        sed 's/java\.naming\.provider\.url=.*/java\.naming\.provider\.url=jnp:\/\/172\.20\.16\.16:2099/' $f > ${f}.1
        mv ${f}.1 ${f}
        cp ${f} $f.local
    done
}

function productionize_adsync {
    find . -name adsync.yml | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/providerUrl:.*/providerUrl: jnp:\/\/172\.20\.16\.16:2099/' $f > ${f}.1
        sed -e 's|\/tmp\/logs\/|/data\/fluigidentity-logs\/|' ${f}.1 > ${f}.2
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.2 > ${f}.3
        sed -e '292 s/false/true/g' ${f}.3 > ${f}.4
	mv ${f}.4 ${f}
        rm -rf ${f}.1 ${f}.2 ${f}.3
        cp ${f} ${f}.local
    done
}

function productionize_backend_rmi {
    find . -name rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp -rf $f ${f}.local
        sed 's/hostname=.*/hostname=172\.20\.16\.12/' ${f} > ${f}.1
	mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

function productionize_backend_scim_rmi {
    find . -name scim.rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/Hostname=localhost*/Hostname=172\.20\.16\.16/' $f > ${f}.1
        sed 's/hostname=.*/hostname=172\.20\.16\.16/' ${f}.1 > ${f}.2
	mv ${f}.2 ${f}
        rm -rf ${f}.1 
        cp ${f} ${f}.local
    done
}

function productionize_frontend_rmi {
    find . -name rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/scimHostname=localhost*/scimHostname=172\.20\.16\.16/' $f > ${f}.1
	mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

function deploy_rest_client_to_snapshot {
    cd service/rest-client
    mvn deploy:deploy-file \
        -Dfile=target/rest-client-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://archiva.fluigidentity.com:8580/repository/totvslabs-release/
    cd -
}

function deploy_idm_common_model_to_snapshot {
    cd idm-common-model
    mvn deploy:deploy-file \
        -Dfile=target/idm-common-model-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://archiva.fluigidentity.com:8580/repository/totvslabs-release/
    cd -
}

function deploy_saml_java_toolkit_to_snapshot {
    cd security/protocol/saml-java-toolkit
    mvn deploy:deploy-file \
        -Dfile=target/saml-java-toolkit-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://archiva.fluigidentity.com:8580/repository/totvslabs-release/
    cd -
}

function deploy_saml_java_rest_client_to_snapshot {
    cd security/protocol/SamlRestClient/saml-java-rest-client
    mvn deploy:deploy-file \
        -Dfile=target/saml-java-rest-client-1.0.jar \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://archiva.fluigidentity.com:8580/repository/totvslabs-release/
    cd -
}

function deploy_saml_rest_toolkit_to_snapshot {
    cd security/protocol/saml-rest-toolkit
    mvn deploy:deploy-file \
        -Dfile=target/saml-rest-toolkit-1.0.war \
        -DpomFile=pom.xml \
        -DrepositoryId=fluigidentity.snapshot \
        -Durl=http://archiva.fluigidentity.com:8580/repository/totvslabs-release/
    cd -
}

function check_error {
        if [  $? -ne 0 ] ; then
        exit -1
        fi
}

DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/data/build/fluigidentity-br-prod

if [ ! -e $FI_HOME ]; then
  mkdir -p $FI_HOME
fi

if [ $# -eq 1 ]; then
    branch=$1
    
    #if [ -n $branch ]; then
    BRANCH="$branch"
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
    GIT_BACKEND=git@github.com:TOTVS/${BACKEND}.git
    GIT_FRONTEND=git@github.com:TOTVS/${FRONTEND}.git
   
    # clone repos 
    cd $FI_HOME/
    mkdir $BRANCH && cd $BRANCH 
    # for repo in $GIT_BACKEND $GIT_FRONTEND; do
    #     echo "git clone -o master $repo"
    #     git clone -b $BRANCH $repo
    #done 

    git clone -b $branch $GIT_BACKEND
check_error
    git clone -b $branch $GIT_FRONTEND
check_error

    cd $FI_HOME/
    ###
    rm -f latest
    ln -s $BRANCH latest

    cd $FI_HOME/latest
 
    ### BACKEND BUILD FIRST
    export JAVA_HOME="/opt/jdk"
    export MVN=/usr/local/maven/bin
    echo "Build all jar files,"
    cd $FI_HOME/$BRANCH/$BACKEND
    $MVN/mvn clean install -Dmaven.test.skip=true 
check_error
    $MVN/mvn clean package -Dmaven.test.skip=true -Pall-jars
check_error
    $MVN/mvn deploy -Pproduction.release -Dmaven.test.skip=true 
check_error
    productionize_backend_rmi
check_error
    productionize_backend_scim_rmi
check_error
 
    ### GRAILS BUILD
    JAVA_HOME=/opt/jdk
check_error
    GRAILS=/usr/local/grails/bin
    cd $FI_HOME/$BRANCH/$FRONTEND/idm-cloudpass
    productionize_frontend_rmi
check_error
    echo "Build frontend"
    $GRAILS/grails clean
    $GRAILS/grails refresh-dependencies 
    $GRAILS/grails compile 
    $GRAILS/grails war
check_error

    ## Setting PROD ENV 
    cd $FI_HOME/$BRANCH/$BACKEND

    echo "productionize keystore.server.properties"
     productionize_keystore_properties
    echo "enable search"
     enable_search
    echo "productionize server.properties"
     productionize_server_properties
    echo "productionize adsync"
     productionize_adsync    
     productionize_keystore_yml
    echo "productionize rest"
     productionize_rest_yml
    echo "enable aws"
     enable_aws
    echo "productionize hornetQ server"
     productionize_hornetq

    cd $FI_HOME/$BRANCH 
    echo "Pre-Packing"
    pre-packaging

### Make deb packing

    FPM=/usr/local/bin/fpm
    RELEASE=`echo $branch| cut -d'-' -f2`
    cd $FI_HOME/$BRANCH
    $FPM -s dir -t deb -n fluigidentity -v $RELEASE --description "Fluigidentity Software" --url 'https://www.fluigidentity.com' cloudpass
    echo "builds and package are done... enjoy !!!"
###
    cd $FI_HOME/$BRANCH/
    echo "sync to local repo"
    copy_to_repo
    update-packages
else

    echo -e "\n\nUsage: $0 {branch name}"
    echo -e "ex: $0 identity-1.1\n\n"

fi
