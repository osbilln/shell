#!/bin/bash -e

. /etc/profile
#. /usr/bin/build_envs

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
        sed -e 's|\/tmp\/logs\/|/data\/fluigidentity-logs\/|' ${f}.0 > ${f}.1
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
        sed -e '256 s/false/true/g' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
        rm -rf ${f}.0 ${f}.1
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
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f} >  ${f}.1
        mv ${f}.1 ${f}
        cp $f ${f}.local
        done
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

function va_post_build {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1/backend/build/config
    va_keystore_properties
    va_keystore_yml
    va_search_yml
    va_rest_yml
    va_server_properties
    va_adsync_yml
    va_hornetq 
    va_aws_yml
}

DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/data/build/fluigidentity/$2

if [ ! -e $FI_HOME ]; then
  mkdir -p $FI_HOME
fi

source utility
source devbuild

if [ $# -eq 4 ]; then
   mk_dir_build $1 $2
   pull_backend $1 $2 $3
   pull_frontend $1 $2 $4
   pull_data $1 $2 
   build_backend $1 $2 $3
   build_frontend $1 $2 $4
   va_post_build $1 $2
   deb_package $1 $2
   copy_to_repo $1 $2
   latest $1 $2
else
    echo ""
    echo -e "\n\nUsage: $0 {branch name} {ENV: prod|qa|qa1a|qa1b|va} {master} {master}\n\n"
    echo -e "ex: $0 identity-1.1 qa backend:branch frontend:branch data:branch security:branch \n\n"
    echo ""
fi
