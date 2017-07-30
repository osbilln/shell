#!/bin/bash -e
set -x

. /etc/profile
#. /usr/bin/build_envs

function qa1b_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f} > ${f}.1
        mv ${f}.1 ${f}
        # backup the file
        cp ${f} ${f}.local
    done
}

function qa1b_keystore_yml {
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

function qa1b_search_yml {
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
       rm ${f}.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7
       cp $f ${f}.local
    done
}

function qa1b_rest_yml {
        find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/g' ${f} >  ${f}.0
        sed -e 's|\/tmp\/logs\/scim|/data\/fluigidentity-logs\/rest|' ${f}.0 > ${f}.1
        sed 's/fluigIdentityServerUrl\: http\:\/\/localhost\:8080/fluigIdentityServerUrl\: http\:\/\/qa1b\.thecloudpass\.com\:8080/g' ${f}.1 >  ${f}.2
        sed -e '256 s/false/true/g' ${f}.2 > ${f}.3
        mv ${f}.3 ${f}
        rm -rf ${f}.0 ${f}.1 ${f}.2
        cp $f ${f}.local
    done
}

function qa1b_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/couchbaseAdminPwd=password/couchbaseAdminPwd=OyIcyM6djb02cWAaNOnr/g' ${f} > ${f}.2
        sed 's/email_admin_name=.*/email_admin_name=kungwang/g' ${f}.2 > ${f}.3
        sed 's/email_admin_password=.*/email_admin_password=u5378Ey25eU153h/g' ${f}.3 > ${f}.4
        sed 's/smtp_host=.*/smtp_host=smtp\.sendgrid\.net/g' ${f}.4 > ${f}.5
        sed 's/companyDomainSuffix=\.fluigidentity\.com/companyDomainSuffix=\.thecloudpass\.com/g' ${f}.5 > ${f}.6
        sed 's/baseUrlForMetadata=https\:\/\/app\.fluigidentity\.com\/cloudpass\//baseUrlForMetadata=https\:\/\/qa1b\.thecloudpass\.com\/cloudpass\//g' ${f}.6 > ${f}.7
#        sed 's/searchUrl=.*/searchUrl=http:\/\/127\.0\.0\.1:18084/search' ${f}.7 > ${f}.8
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.7 >  ${f}.8
        mv ${f}.8 ${f}
        rm ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 
        cp $f ${f}.local
    done
}

function qa1b_adsync_yml {
    find . -name adsync.yml | while read f; do
        echo "No need to change"
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f} > ${f}.1
        sed -e '292 s/false/true/g' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
        rm -rf ${f}.1
        # backup the file
        cp $f ${f}.local
    done
}

function qa1b_hornetq {
    find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
    done
}

function qa1b_aws_yml {
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

function qa1b_post_build {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1/backend/build/config
    qa1b_keystore_properties
    qa1b_keystore_yml
    qa1b_search_yml
    qa1b_rest_yml
    qa1b_server_properties
    qa1b_adsync_yml
    qa1b_hornetq 
    qa1b_aws_yml
}

DATE=`date '+%Y-%m-%d-%H:%M:%S'`

if [ ! -e $FI_HOME ]; then
  mkdir -p $FI_HOME
fi

source utility
source devbuild

if [ $# -eq 4 ]; then
   mk_dir_build $1 $2
   pull_backend $1 $2 $3
   pull_frontend $1 $2 $4
   build_backend $1 $2 $3
   build_frontend $1 $2 $4
   qa1b_post_build $1 $2
   deb_package $1 $2
   copy_to_repo $1 $2
   latest $1 $2
else
    echo ""
    echo -e "\n\nUsage: $0 {branch name} {ENV: prod|qa|qa1a|qa1b|va} {master} {master}\n\n"
    echo -e "ex: $0 identity-1.1 qa backend:branch frontend:branch data:branch security:branch \n\n"
    echo ""
fi
