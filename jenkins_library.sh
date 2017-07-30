#!/bin/bash -e
##-------------------------------------------------------------------
## File : jenkins_library.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-08-26>
## Updated: Time-stamp: <2014-08-26 15:44:22>
##-------------------------------------------------------------------
. common_library.sh
function copy_to_repo {
    find . -name *.deb | while read f; do 
       # if there is a backup file, restore it
       if [ -e ${f} ]; then
           sudo cp -r ${f} /var/www/packages/.
           sudo update-packages
       fi
    done
}

function deb_package {
    ## Make deb packing
    fi_home="/data/build/fluigidentity/$2"
    fpm=/usr/local/bin/fpm
    release=`echo $1 | cut -d'-' -f2`
    
    if [ -e cloudpass ]; then
      rm -rf cloudpass
    fi
    cd $fi_home/$1
    mkdir -p cloudpass/backend cloudpass/frontend/idm-cloudpass
    cp -r backend/build cloudpass/backend
    cp -r frontend/idm-cloudpass/target cloudpass/frontend/idm-cloudpass/
    $fpm -s dir -t deb -n fluigidentity-$2 -v $release --description "Fluigidentity Software" --url 'https://www.fluigidentity.com' cloudpass/
check_error    
}

####### VA #######

function va_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed -e 's|\/tmp\/logs\/|/data\/fluigidentity-logs\/|' ${f} > ${f}.1
        mv ${f}.1 ${f}
        # backup the file
        cp ${f} ${f}.local
    done
}

function va_keystore_yml {
    find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed -e '89 s/false/true/g' ${f} > ${f}.0
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.0 > ${f}.1
        mv ${f}.1 ${f}
        rm ${f}.0 
        # backup the file
        cp ${f} ${f}.local
    done
}

function va_rest_yml {
        find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/g' ${f} >  ${f}.0
        sed -e 's/\/data\/logs/\/data\/fluigidentity-logs/g' ${f}.0 > ${f}.1
        sed 's/fluigIdentityServerUrl\: http\:\/\/localhost\:8080/fluigIdentityServerUrl\: http\:\/\/va\.thecloudpass\.com\:8080/g' ${f}.1 >  ${f}.2
        sed -e '256 s/false/true/g' ${f}.2 > ${f}.3
        mv ${f}.3 ${f}
        rm -rf ${f}.0 ${f}.1 ${f}.2 
        cp $f ${f}.local
    done
}

function va_search_yml {
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
       sed -e '14 s/false/true/' ${f}.4 > ${f}.5
       sed -e '27 s|"com.totvslabs.idm.service.search.analyzer.LowerCaseEnglishKeywordAnalyzer"|"com.totvslabs.idm.service.search.analyzer.LowerCaseWhiteSpacePorterStemAnalyzer"|g' ${f}.5 > ${f}.6
       sed -e '59 s/false/true/g' ${f}.6 > ${f}.7
       sed -e '70 s|"com.totvslabs.idm.service.search.analyzer.LowerCaseEnglishKeywordAnalyzer"|"com.totvslabs.idm.service.search.analyzer.LowerCaseWhiteSpacePorterStemAnalyzer"|g' ${f}.7 > ${f}.8
       sed 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.8 > ${f}.9
       sed -e '653 s/false/true/g' ${f}.9 > ${f}.10
       mv ${f}.10 ${f}
       rm ${f}.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9
       cp $f ${f}.local

    done
}

function va_adsync_yml {
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

function va_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed 's/\#email_admin_name=.*/email_admin_name=XXXXXXXXXXXXX/g' ${f} > ${f}.1
        sed 's/\#email_admin_password=.*/email_admin_password=XXXXXXXXXXXXX/g' ${f}.1 > ${f}.2
        sed 's/\#admin_email_address=.*/admin_email_address=XXXXXXXXXXXXX/g' ${f}.2 > ${f}.3
        sed 's/\#smtp_host= .*/smtp_host=XXXXXXXXXXXXX/g' ${f}.3 > ${f}.4
        sed 's/smtp_port=587/smtp_host=XXXXXXXXXXXXX/g' ${f}.4 > ${f}.5
        sed 's/email_admin_name=.*/email_admin_name=XXXXXXXXXXXXX/g' ${f} > ${f}.6
        sed 's/email_admin_password=.*/email_admin_password=XXXXXXXXXXXXX/g' ${f}.6 > ${f}.7
        sed 's/admin_email_address=.*/admin_email_address=XXXXXXXXXXXXX/g' ${f}.7 > ${f}.8
        sed 's/smtp_host= .*/smtp_host=XXXXXXXXXXXXX/g' ${f}.8 > ${f}.9
        sed 's/smtp_port=587/smtp_host=XXXXXXXXXXXXX/g' ${f}.9 > ${f}.10
    sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.10 >  ${f}.11
        mv ${f}.11 ${f}
        rm ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9 ${f}.10 
        cp $f ${f}.local
        done
}

function va_packaging {
 # Backend  
    rm -rf cloudpass
    mkdir -p cloudpass/backend/build/bin cloudpass/frontend/idm-cloudpass/target
    ###
    cp -rp backend/build/bin/keystore_server_start.sh cloudpass/backend/build/bin
    cp -r backend/build/bin/search_service_start.sh cloudpass/backend/build/bin
    cp -r backend/build/bin/rest_service_start.sh cloudpass/backend/build/bin
    cp -r backend/build/bin/rmistart.sh cloudpass/backend/build/bin
    cp -r backend/build/bin/adsync_service_start.sh cloudpass/backend/build/bin
    cp -rp backend/build/bin/upgrade_script.sh cloudpass/backend/build/bin

    cp -rp backend/build/dist cloudpass/backend/build/
    cp -rp backend/build/lib cloudpass/backend/build/
    cp -rp backend/build/config cloudpass/backend/build/

 # mv backend/bin cloudpass/backend
 # Frontend 
    
    cp -r frontend/idm-cloudpass/target/cloudpass-0.1.war cloudpass/frontend/idm-cloudpass/target/.
    cp -rp data cloudpass/
}


function va_aws_yml {
    find . -name aws.yml | while read f; do 
       # if there is a backup file, restore it
       # if [ -e ${f}.local ]; then
       #   cp ${f}.local $f
       # fi
       # backup the original file
       cp $f ${f}.local
       sed 's/ttl:.*/ttl: 60/g' ${f} > ${f}.1
       sed 's/accessId: .*/accessId: XXXXXXXXXXXXX/g' ${f}.1 > ${f}.2
       sed 's/accessKey: .*/accessKey: XXXXXXXXXXXXX/g' ${f}.2 > ${f}.3
       sed 's/hostedZoneId: .*/hostedZoneId: XXXXXXXXXXXXX/g' ${f}.3 > ${f}.4
       mv ${f}.4 ${f}
       rm ${f}.1 ${f}.2 ${f}.3
       cp $f ${f}.local
    done
}

function va_hornetq {
    find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
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

function pull_backend {
    #TODO
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home
    mkdir $1 && cd $1
    branch=$3
    backend=git@github.com:TOTVS/backend.git
    if [ $branch == master ]; then
        git clone -o $branch $backend
    else 
        git clone -b $branch $backend
    fi
}

function pull_frontend {
    #TODO
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1
    frontend="git@github.com:TOTVS/frontend.git"
    echo "$3"
    branch="$3"
    if [ "$branch" == master ]; then
        git clone -o $branch $frontend
    else 
        git clone -b $branch $frontend
    fi
}

function pull_data {
    #TODO
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1
    data=git@github.com:TOTVS/data.git
    branch=$3
    if [ $branch == master ]; then
        git clone -o $branch $data
    else 
        git clone -b $branch $data
    fi
}

function pull_security {
    #TODO
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1
    data=git@github.com:TOTVS/data.git
    branch=$4
    if [ $branch == master ]; then
        git clone -o $branch $data
    else 
        git clone -b $branch $security
    fi
}

function build_backend {
### BUILD BACKEND FIRST
    MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=1024m"
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1/backend
    echo "Build all jar files,"
    mvn clean install -Dmaven.test.skip=true 
    mvn clean package -Dmaven.test.skip=true -Pall-jars
}

function build_frontend {
### GRAILS FRONTEND 
    export JAVA_HOME=/opt/jdk
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1/frontend/idm-cloudpass
    grails_home=/usr/local/grails/bin
    $grails_home/grails clean
    $grails_home/grails refresh-dependencies 
    $grails_home/grails compile 
    $grails_home/grails war
}

function build_security {
    ### SECURITY
    # cd $FI_HOME/$BRANCH/$SECURITY/protocol
    mvn clean install -Dmaven.test.skip=true
####### DEV BUILD #######
}


function mk_dir_build {
    DATE=`date '+%Y-%m-%d-%H:%M:%S'`
    fi_home="/data/build/fluigidentity/$2"
    if [ ! -e $fi_home ]; then
        mkdir -p $fi_home
    fi
    old_dir="$fi_home/$2/$1"
    if  [ -e $old_dir ]; then
        mv $old_dir $old_dir_$DATE
        echo "backup existing folder"
    fi
}

function latest {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home
    rm -f latest
    ln -s $1 latest
}

## File : jenkins_library.sh ends
