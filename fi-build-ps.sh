#!/bin/bash -e
set -x

. /etc/profile
#. /usr/bin/build_envs


function dev_ps_keystore_yml {
   find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/listenAddress:.*/listenAddress: "172.20.18.17"/' ${f} > ${f}.1
        sed 's/address: \"127.0.0.1\"/address: \"172.20.18.17\"/g' $f.1 > ${f}.2
        sed 's/address: \"localhost\"/address: \"172.20.18.17\"/g' $f.2 > ${f}.3
        sed 's/remote: \"127.0.0.1\"/remote: \"172.20.18.17\"/g' $f.3 > ${f}.4
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.4 > ${f}.5
        sed -e 's|\/tmp\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.5 > ${f}.6
        sed -e '89 s/false/true/g' ${f}.6 > ${f}.7
        mv ${f}.7 ${f}
        rm -rf ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6
        cp $f ${f}.local
    done
}

function dev_ps_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        cp ${f} ${f}.local
    done
}

function dev_ps_search_yml {
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
       sed 's/providerUrl.*/providerUrl: "jnp:\/\/172\.20\.18\.17:2099"/' ${f}.10 > ${f}.11
       mv ${f}.11 ${f}
       rm $f.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9 ${f}.10
       cp $f ${f}.local

    done
}

function dev_ps_rest_yml {

  find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/' ${f} > ${f}.0
        sed 's/fluigIdentityServerUrl:.*/fluigIdentityServerUrl: https\:\/\/app\.psfluigidentity\.com/' ${f}.0 > ${f}.1
        sed 's/providerUrl.*/providerUrl: "jnp:\/\/172\.20\.18\.17:2099"/' ${f}.1 > ${f}.2
        sed -e '229 s/false/true/' ${f}.2 > ${f}.3
        sed 's/listenAddress:.*/listenAddress: "172\.20\.18\.17"/g' ${f}.3 > ${f}.4
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.4 > ${f}.5
        sed -e '256 s/false/true/g' ${f}.5 > ${f}.6
        mv ${f}.6 $f
        rm -rf ${f}.0 ${f}.1  ${f}.2 ${f}.3 ${f}.4 ${f}.5
        cp $f ${f}.local
    done

}

function dev_ps_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/couchbaseServerUrls=.*/couchbaseServerUrls=172\.20\.18\.17:8091;/' $f > ${f}.1
        sed 's/keyStoreServer=.*/keyStoreServer=172\.20\.18\.17/' ${f}.1 > ${f}.2
        sed 's/companyDomainSuffix=\.fluigidentity\.com/companyDomainSuffix=\.psfluigidentity\.com/g' ${f}.2 > ${f}.3
        sed 's/app.fluigidentity.com/app.psfluigidentity.com/g' ${f}.3 > ${f}.4
        sed 's/searchUrl=.*/searchUrl\=http\:\/\/172.20.18.17\:18084\/search/' ${f}.4 > ${f}.5
        sed 's/email_admin_name=.*/email_admin_name=support@fluigidentity.com/g' ${f}.5 > ${f}.6
        sed 's/email_admin_password=.*/email_admin_password=s\[78Q4-52331FE)/g' ${f}.6 > ${f}.7
        sed 's/smtp_host=.*/smtp_host=mail\.fluigidentity\.com/g' ${f}.7 > ${f}.8
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.8 >  ${f}.9
        mv ${f}.9 $f
        rm ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8
        cp ${f} $f.local
    done
}

function dev_ps_adsync_yml {
    find . -name adsync.yml | while read f; do
        echo "No need to change"
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed 's|\/tmp\/|\/data\/|g' ${f} > ${f}.1
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.1 > ${f}.2
        sed -e '292 s/false/true/g' ${f}.2 > ${f}.3
        mv ${f}.3 ${f}
        rm -rf ${f}.1 ${f}.2 
        # backup the file
        cp $f ${f}.local
    done
}

function dev_ps_hornetq {
  find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/java\.naming\.provider\.url=.*/java\.naming\.provider\.url=jnp:\/\/172\.20\.18\.17:2099/' $f > ${f}.1
        mv ${f}.1 ${f}
        cp ${f} $f.local
    done

}

function dev_ps_aws_yml {
    find . -name aws.yml | while read f; do
       # if there is a backup file, restore it
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local
       sed 's/ttl:.*/ttl: 60/g' $f > ${f}.1
       sed 's/enabled: false/enabled: true/g' ${f}.1 > ${f}.2
       sed 's/defaultCNameARecord: "app\.fluigidentity.com."/defaultCNameARecord: "app\.psfluigidentity\.com\."/g' ${f}.2 > ${f}.3
       sed 's/domain: "fluigidentity\.com"/domain: "psfluigidentity\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z2LWCQRAL5W90L"/g' ${f}.4 > ${f}.5
       mv ${f}.5 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
       cp $f ${f}.local
    done
}

function dev_ps_post_build {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1/backend/build/config
    dev_ps_keystore_properties
    dev_ps_keystore_yml
    dev_ps_search_yml
    dev_ps_rest_yml
    dev_ps_server_properties
    dev_ps_adsync_yml
    dev_ps_hornetq 
    dev_ps_aws_yml
}

DATE=`date '+%Y-%m-%d-%H:%M:%S'`
FI_HOME=/data/build/fluigidentity/devtest

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
   dev_ps_post_build $1 $2
   deb_package $1 $2
   copy_to_repo $1 $2
   latest $1 $2
else
    echo ""
    echo -e "\n\nUsage: $0 {branch name} {ENV: prod|qa|qa1a|qa1b|va} {master} {master}\n\n"
    echo -e "ex: $0 identity-1.1 qa backend:branch frontend:branch data:branch security:branch \n\n"
    echo ""
fi
