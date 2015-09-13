#!/bin/bash -e
set -x

. /etc/profile
#. /usr/bin/build_envs

function qa1a_search_yml {
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
       sed -e '653 s|enabled: false|enabled: true|g' ${f}.7 > ${f}.8
       sed -e 's|reindex: true|reindex: false|g' ${f}.8 > ${f}.9
       sed 's/providerUrl.*/providerUrl: "jnp:\/\/sffiqa03:2099"/' ${f}.9 > ${f}.10
       mv ${f}.10 ${f}
       rm $f.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9
       cp $f ${f}.local

    done
}

function qa1a_aws_yml {
    find . -name aws.yml | while read f; do
       # if there is a backup file, restore it
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local
       sed 's/ttl:.*/ttl: 60/g' $f > ${f}.1
       sed 's/enabled: false/enabled: true/g' ${f}.1 > ${f}.2
       sed 's/defaultCNameARecord: "qa\.fluigidentity.com."/defaultCNameARecord: "app\.qafluigidentity\.com\."/g' ${f}.2 > ${f}.3
       sed 's/domain: "fluigidentity\.com"/domain: "qafluigidentity\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z2J4Q8E0G8QRAN"/g' ${f}.4 > ${f}.5
       mv ${f}.5 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
       cp $f ${f}.local
    done
}

function qa1a_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/couchbaseServerUrls=.*/couchbaseServerUrls=sffiqa07:8091;sffiqa08:8091;/g' $f > ${f}.1
        sed 's/keyStoreServer=.*/keyStoreServer=sffiqa05/g' ${f}.1 > ${f}.2
        ## Replace SearchURL
        sed 's/searchUrl=.*/searchUrl\=http:\/\/sffqa03:18084\/search/g' ${f}.2 > ${f}.3
        sed 's/email_admin_name=.*/email_admin_name=support@fluigidentity.com/g' ${f}.3 > ${f}.4
        sed 's/email_admin_password=.*/email_admin_password=s\[78Q4-52331FE)/g' ${f}.4 > ${f}.5
        sed 's/smtp_host=.*/smtp_host=mail\.fluigidentity\.com/g' ${f}.5 > ${f}.6
        sed 's/companyDomainSuffix=\.fluigidentity\.com/companyDomainSuffix=\.qafluigidentity\.com/g' ${f}.6 > ${f}.7
        sed 's/baseUrlForMetadata=https\:\/\/app\.fluigidentity\.com\/cloudpass\//baseUrlForMetadata=https\:\/\/app\.qafluigidentity\.com\/cloudpass\//g' ${f}.7 > ${f}.8
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.8 >  ${f}.9
        sed 's/couchbaseAdminPwd=.*/couchbaseAdminPwd=t5NjMnbgAysH/' ${f}.9 > ${f}.10
        mv ${f}.10 $f
        rm ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9
        cp ${f} $f.local
    done
}

function qa1a_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp ${f} ${f}.local
        # sed 's/keyStorePassword=totvslabs/keyStorePassword=M\@5\}i\%\>\<\!28\&3\)v/g' ${f} > ${f}.1
        #
        done
}

function qa1a_keystore_yml {
  find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/listenAddress:.*/listenAddress: "sffiqa05"/g' ${f} > ${f}.1
        sed 's/address: \"127.0.0.1\"/address: "sffiqa05"/g' $f.1 > ${f}.2
        sed 's/address: \"localhost\"/address: "sffiqa05"/g' $f.2 > ${f}.3
        sed 's/remote: \"127.0.0.1\"/remote: "sffiqa06"/g' $f.3 > ${f}.4
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.4 > ${f}.5
        sed -e '89 s/false/true/g' ${f}.5 > ${f}.6
        mv ${f}.6 ${f}
        rm -rf ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 
        cp $f ${f}.local
    done
}

function qa1a_rest_yml {
        find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/' ${f} > ${f}.0
        sed 's/fluigIdentityServerUrl:.*/fluigIdentityServerUrl: https\:\/\/app\.qafluigidentity\.com/' ${f}.0 > ${f}.1
        sed 's/providerUrl.*/providerUrl: "jnp:\/\/sffiqa03:2099"/' ${f}.1 > ${f}.2
        sed -e '229 s/false/true/' ${f}.2 > ${f}.3
        sed 's/listenAddress:.*/listenAddress: sffiqa03/g' ${f}.3 > ${f}.4
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.4 > ${f}.5
        sed -e '255 s/false/true/g' ${f}.5 > ${f}.6
        mv ${f}.6 $f
        rm -rf ${f}.0 ${f}.1  ${f}.2 ${f}.3 ${f}.4 ${f}.5
        cp $f ${f}.local
    done
}

function qa1a_hornetq {
    find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/java\.naming\.provider\.url=.*/java\.naming\.provider\.url=jnp:\/\/sffiqa03:2099/' $f > ${f}.1
        mv ${f}.1 ${f}
        cp ${f} $f.local
    done
}

function qa1a_adsync_yml {
    find . -name adsync.yml | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/providerUrl:.*/providerUrl: jnp:\/\/sffiqa03:2099/' $f > ${f}.1
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.1 > ${f}.2
        sed -e '292 s/false/true/g' ${f}.2 > ${f}.3
  mv ${f}.3 ${f}
        rm -rf ${f}.1 ${f}.2
        cp ${f} ${f}.local
    done
}

function qa1a_backend_rmi {
    find . -name rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/hostname=localhost/hostname=sffiqa01/' $f > ${f}.1
      mv ${f}.1 ${f}
#        rm -rf ${f}.1 
        cp ${f} ${f}.local
    done
}

function qa1a_backend_scim {
    find . -name scim.rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/hostname=localhost/hostname=sffiqa01/' $f > ${f}.1
        mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

function qa1a_frontend_rmi {
    find . -name rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/hostname=localhost/hostname=sffiqa03/' $f > ${f}.1
  mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

function qa1a_logback_xml {
    find . -name logback.xml | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/127.0.0.1/sffiqa03/' $f > ${f}.1
    mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

function qa1a_post_build {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1/backend/build/config
    
    #qa1a_keystore_properties
    #qa1a_keystore_yml
    #qa1a_search_yml
    qa1a_rest_yml
    qa1a_server_properties
    qa1a_adsync_yml
    qa1a_hornetq 
    qa1a_aws_yml
    qa1a_logback_xml
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
   build_backend $1 $2 $3
   build_frontend $1 $2 $4
   qa1a_post_build $1 $2
   deb_package $1 $2
   copy_to_repo $1 $2
   latest $1 $2
else
    echo ""
    echo -e "\n\nUsage: $0 {branch name} {ENV: prod|qa|qa1a|qa1b|va} {master} {master}\n\n"
    echo -e "ex: $0 identity-1.1 qa backend:branch frontend:branch data:branch security:branch \n\n"
    echo ""
fi
