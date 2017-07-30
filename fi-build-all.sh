#!/bin/bash -e
# set -x
source /etc/profile
function log()
{
    local msg=${1?} >> $LOG_FILE
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n" >> $LOG_FILE
}

function mk_dir()
{
    local dir=${1?}
    if [ ! -e $dir ]; then
        mkdir -p $dir
    fi
}

function check_error {
        if [ $? -ne 0 ] ; then
        exit -1
        fi
}

function gitpull {
  git add .
  git reset --hard 
  git pull
}

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

function dev_packaging {
 # Backend  
    fi_home="/data/build/fluigidentity/$2"
      
}

function dev_keystore_yml {
    find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fibuild-envs
        sed -e '89 s/false/true/g' ${f} > ${f}.0
        sed -e 's|\/tmp|\/data\/|' ${f}.0 > ${f}.1
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
        # backup the file
        rm ${f}.1
        cp ${f} ${f}.local
      fi
    done
}

function dev_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed -e 's|\/tmp\/|\/data\/|' ${f} > ${f}.1
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
        rm ${f}.1
        cp ${f} ${f}.local
    done
}

function dev_search_yml {
    find . -name search.yml | while read f; do
       # first enable everything, and change data folder from /tmp/.. to /data/..
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local

       sed 's/enabled: false/enabled: false/g' $f > $f.0 
       # the enabled flag in inputConfiguration section should be disabled
       sed -e '1,/^inputConfiguration/b' -e 's/enabled: true/enabled: false/g' ${f}.0 > ${f}.1
       # after timeLineConfiguration, enable again
       sed -e '1,/^timeLineConfiguration/b' -e 's/enabled: false/enabled: true/g' ${f}.1 > ${f}.2
       # everything after hornetQServerConfiguration should be disabled
       sed -e '1,/^hornetQServerConfiguration/b' -e 's/enabled: true/enabled: false/g' ${f}.2 > ${f}.3
       sed -e '27 s|"com.totvslabs.idm.service.search.analyzer.LowerCaseEnglishKeywordAnalyzer"|"com.totvslabs.idm.service.search.analyzer.LowerCaseWhiteSpacePorterStemAnalyzer"|g' ${f}.3 > ${f}.4
       sed -e '70 s|"com.totvslabs.idm.service.search.analyzer.LowerCaseEnglishKeywordAnalyzer"|"com.totvslabs.idm.service.search.analyzer.LowerCaseWhiteSpacePorterStemAnalyzer"|g' ${f}.4 > ${f}.5
       sed 's|\/tmp\/|\/data\/|g' $f.5 > ${f}.6
       sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.6 > ${f}.7
       sed -e '653 s/false/true/g' ${f}.7 > ${f}.8
       mv ${f}.8 ${f}
       rm ${f}.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 
       cp $f ${f}.local

    done
}

function dev_rest_yml {
        find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/g' ${f} >  ${f}.0
        sed 's/fluigIdentityServerUrl\: http\:\/\/localhost\:8080/fluigIdentityServerUrl\: http\:\/\/dev\.thecloudpass\.com\:8080/g' ${f}.0 >  ${f}.1
        sed 's|\/tmp\/|\/data\/|g' $f.1 > ${f}.2
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.2 > ${f}.3
        sed -e '256 s/false/true/g' ${f}.3 > ${f}.4
        mv ${f}.4 ${f}
        rm -rf ${f}.0 ${f}.1 ${f}.2 ${f}.3
        cp $f ${f}.local
    done
}

function dev_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        sed 's/app.fluigidentity.com/dev.thecloudpass.com/g' ${f} >  ${f}.1
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.1 >  ${f}.2
        mv ${f}.2 ${f} 
        rm -rf ${f}.1
        fi
        # backup the file
        cp ${f} ${f}.local
    done
}


function dev_adsync_yml {
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

function dev_hornetq {
    find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
    done
}

function dev_aws_yml {
    find . -name aws.yml | while read f; do
       # if there is a backup file, restore it
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local
       sed 's/ttl:.*/ttl: 60/g' $f > ${f}.1
       sed 's/enabled: false/enabled: true/g' ${f}.1 > ${f}.2
       sed 's/defaultCNameARecord: "qa\.fluigidentity.com."/defaultCNameARecord: "dev\.thecloudpass\.com\."/g' ${f}.2 > ${f}.3
       sed 's/domain: "fluigidentity\.com"/domain: "app.thecloudpass\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z2LWCQRAL5W90L"/g' ${f}.4 > ${f}.5
       mv ${f}.5 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
       cp $f ${f}.local
<<<<<<< HEAD
<<<<<<< HEAD
    doneremote
=======
    done
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
    done
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
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
       sed 's/defaultCNameARecord: "qa\.fluigidentity.com."/defaultCNameARecord: "ps\.thecloudpass\.com\."/g' ${f}.2 > ${f}.3
       sed 's/domain: "fluigidentity\.com"/domain: "app.thecloudpass\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z2LWCQRAL5W90L"/g' ${f}.4 > ${f}.5
       mv ${f}.5 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
       cp $f ${f}.local
    done
}

#### qafluigidentity.com
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
       sed 's/providerUrl.*/providerUrl: "jnp:\/\/104\.131\.134\.190\:2099"/' ${f}.9 > ${f}.10
       mv ${f}.10 ${f}
       rm $f.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8 ${f}.9
       cp $f ${f}.local

    done
}

function qa1a_enable_aws {
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
       sed 's/domain: "fluigidentity\.com"/domain: "app.qafluigidentity\.com"/g' ${f}.3 > ${f}.4
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
        sed 's/couchbaseServerUrls=.*/couchbaseServerUrls=107\.170\.212\.114\:8091;162.243.82.119:8091;/g' $f > ${f}.1
        sed 's/keyStoreServer=.*/keyStoreServer=192.241.202.107/g' ${f}.1 > ${f}.2
        ## Replace SearchURL
        sed 's/searchUrl=.*/searchUrl\=http:\/\/104.131.134.190:18084\/search/g' ${f}.2 > ${f}.3
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
        sed 's/listenAddress:.*/listenAddress: "192.241.202.107"/g' ${f} > ${f}.1
        sed 's/address: \"127.0.0.1\"/address: "192.241.202.107"/g' $f.1 > ${f}.2
        sed 's/address: \"localhost\"/address: "192.241.202.107"/g' $f.2 > ${f}.3
        sed 's/remote: \"127.0.0.1\"/remote: "107.170.231.91"/g' $f.3 > ${f}.4
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
        sed 's/providerUrl.*/providerUrl: "jnp:\/\/104\.131\.134\.190\:2099"/' ${f}.1 > ${f}.2
        sed -e '229 s/false/true/' ${f}.2 > ${f}.3
        sed 's/listenAddress:.*/listenAddress: "104.131.134.190"/g' ${f}.3 > ${f}.4
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
        sed 's/java\.naming\.provider\.url=.*/java\.naming\.provider\.url=jnp:\/\/104\.131\.134\.190\:2099/' $f > ${f}.1
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
        sed 's/providerUrl:.*/providerUrl: jnp:\/\/104\.131\.134\.190\:2099/' $f > ${f}.1
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
        sed 's/hostname=localhost/hostname=107\.170\.197\.131/' $f > ${f}.1
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
        sed 's/hostname=localhost/hostname=104.131.134.190/' $f > ${f}.1
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
        sed 's/hostname=localhost/hostname=104.131.134.190/' $f > ${f}.1
  mv ${f}.1 ${f}
        cp ${f} ${f}.local
    done
}

#### qa.fluigidentity.com
function qa_keystore_yml {
    find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed 's/\/tmp\//\/data\//g' $f > ${f}.1
        sed -e '89 s/false/true/g' ${f}.1 > ${f}.2
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.3 > ${f}.3
        mv ${f}.3 ${f}
        rm ${f}.1  ${f}.2
        # backup the file
        cp ${f} ${f}.local
    done
}

function qa_search_yml {
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
       # Enable logger
       # enable suggestion reindex
       mv ${f}.8 ${f}
       rm rm ${f}.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7
       cp $f ${f}.local

    done
}

function qa_rest_yml {
        find . -name rest.yml| while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/prodEnvironment\: false/prodEnvironment\: true/g' ${f} >  ${f}.0
        sed -e 's|\/data\/logs\/scim|/data\/fluigidentity-logs\/rest|' ${f}.0 > ${f}.1
        sed -e '256 s/false/true/g' ${f}.1 > ${f}.2
        sed 's/fluigIdentityServerUrl\: http\:\/\/localhost\:8080/fluigIdentityServerUrl\: http\:\/\/qa\.fluigidentity\.com\:8080/g' ${f}.0 >  ${f}.1
        mv ${f}.2 ${f}
        rm ${f}.0 ${f}.1
        cp $f ${f}.local
    done
}


function qa_server_properties {
    find . -name server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/couchbaseAdminPwd=password/couchbaseAdminPwd=OyIcyM6djb02cWAaNOnr/' ${f} > ${f}.2
        sed 's/email_admin_name=.*/email_admin_name=kungwang/g' ${f}.2 > ${f}.3
        sed 's/email_admin_password=.*/email_admin_password=u5378Ey25eU153h/g' ${f}.3 > ${f}.4
        sed 's/smtp_host=.*/smtp_host=smtp\.sendgrid\.net/g' ${f}.4 > ${f}.5
        sed 's/companyDomainSuffix=\.fluigidentity\.com/companyDomainSuffix=\.fluigidentity\.com/g' ${f}.5 > ${f}.6
        sed 's/baseUrlForMetadata=https\:\/\/app\.fluigidentity\.com\/cloudpass\//baseUrlForMetadata=https\:\/\/qa\.fluigidentity\.com\/cloudpass\//g' ${f}.6 > ${f}.7
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.7 > ${f}.8
        sed 's/couchbaseAdminPwd=.*/couchbaseAdminPwd=OyIcyM6djb02cWAaNOnr/'g ${f}.8 > ${f}.9
        mv ${f}.9 $f
        rm ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8
        cp $f ${f}.local
    done
}

function qa_adsync_yml {
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

function qa_hornetq {
    find . -name hornetq.jndi.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
    done
}

function qa_aws_yml {
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
       mv ${f}.3 ${f}
       rm ${f}.1 ${f}.2
       cp $f ${f}.local
    done
}

### qa1b.thecloudpass.com functions
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
        sed 's/remoteCallsEnabled=false/remoteCallsEnabled=true/g' ${f}.8 >  ${f}.9
        mv ${f}.9 $f
        rm ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7 ${f}.8
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
       sed 's/domain: "app.fluigidentity\.com"/domain: "app.thecloudpass\.com"/g' ${f}.3 > ${f}.4
       sed 's/hostedZoneId: "Z3B4GAQ1PEMI0D"/hostedZoneId: "Z2LWCQRAL5W90L"/g' ${f}.4 > ${f}.5
       mv ${f}.5 ${f}
       rm ${f}.1 ${f}.2 ${f}.3 ${f}.4
       cp $f ${f}.local
    done
}

### Prod function
function prod_keystore_properties {
    find . -name keystore.server.properties | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/keyStorePassword=.*/keyStorePassword=M@5}i%><!28\&3)v/g' ${f} > ${f}.1
        sed 's/127.0.0.1/172.20.16.14/' > ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
        rm ${f}.1 
        cp ${f} $f.local
    done
}

function prod_keystore_yml {
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
        sed -e 's|\/tmp\/logs\/|/data\/fluigidentity-logs\/|' ${f}.5 > ${f}.6
        sed -e '89 s/false/true/g' ${f}.6 > ${f}.7
        mv ${f}.7 ${f}
        rm -rf ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6
        cp $f ${f}.local
    done
}


function prod_search_yml {
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
       rm $f.0 ${f}.1 ${f}.2 ${f}.3 ${f}.4 ${f}.5 ${f}.6 ${f}.7
       cp $f ${f}.local

    done
}

function prod_rest_yml {
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
        sed -e 's|\/data\/logs\/|/data\/fluigidentity-logs\/|' ${f}.4 > ${f}.5
        sed -e '256 s/false/true/g' ${f}.5 > ${f}.6
        mv ${f}.6 $f
        rm -rf ${f}.0 ${f}.1  ${f}.2 ${f}.3 ${f}.4 ${f}.5
        cp $f ${f}.local
    done
}

function prod_server_properties {
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

function prod_adsync_yml {
    find . -name adsync.yml | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/providerUrl:.*/providerUrl: jnp:\/\/172\.20\.16\.16:2099/' $f > ${f}.1
        sed -e 's|\/tmp\/logs\/|/data\/fluigidentity-logs\/|' ${f}.1 > ${f}.2
        sed -e '292 s/false/true/g' ${f}.2 > ${f}.3
          mv ${f}.3 ${f}
        rm -rf ${f}.1 ${f}.2
        cp ${f} ${f}.local
    done
}

function prod_hornetq {
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

function prod_aws_yml {
    find . -name aws.yml | while read f; do 
       # if there is a backup file, restore it
       if [ -e ${f}.local ]; then
           cp ${f}.local $f
       fi
       # backup the original file
       cp $f ${f}.local
       sed 's/ttl:.*/ttl: 60/g' $f > ${f}.1
       sed 's/enabled: false/enabled: true/g' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
       /bin/rm ${f}.1
       cp ${f} $f.local
    done
}

function prod_backend_rmi {
    find . -name rmi.server.properties | while read f; do
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/scimHostname=localhost*/scimHostname=172\.20\.16\.16/' $f > ${f}.1
        sed 's/hostname=.*/hostname=172\.20\.16\.11/' ${f}.1 > ${f}.2
         mv ${f}.2 ${f}
        rm -rf ${f}.1 
        cp ${f} ${f}.local
    done
}

function prod_frontend_rmi {
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

function post_build_dev {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1
    dev_keystore_properties
    dev_keystore_yml
    dev_search_yml
    dev_rest_yml
    dev_server_properties
    dev_adsync_yml
    dev_hornetq 
    deb_package
    copy_to_repo 
}

function post_build_qa1a {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1
    qa1a_keystore_properties
    qa1a_keystore_yml
    qa1a_search_yml
    qa1a_rest_yml
    qa1a_server_properties
    qa1a_adsync_yml
    qa1a_hornetq 
}

function post_build_qa1b {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1
    qa1b_keystore_properties
    qa1b_keystore_yml
    qa1b_search_yml
    qa1b_rest_yml
    qa1b_server_properties
    qa1b_adsync_yml
    qa1b_hornetq 
}

function post_build_prod {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1
    prod_keystore_properties
    prod_keystore_yml
    prod_search_yml
    prod_rest_yml
    prod_server_properties
    prod_adsync_yml
    prod_hornetq 
}

function post_build_va {
    fi_home="/data/build/fluigidentity/$2"
    cd $fi_home/$1
    va_keystore_properties
    va_keystore_yml
    va_search_yml
    va_rest_yml
    va_server_properties
    va_adsync_yml
    va_hornetq 
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

if [ $# -eq 4 ]; then
    if [ $2 == "prod" ]; then
        echo " Build the $1 release"
        mk_dir_build $1 $2
        pull_backend $1 $2 $3
        pull_frontend $1 $2 $4
        build_backend $1 $2 $3
        build_frontend $1 $2 $4
        post_build_prod $1 $2
        deb_package $1 $2 
        copy_to_repo $1 $2
        latest $1 $2
    fi    
    if [ $2 == "qa1a" ]; then
        mk_dir_build $1 $2
        pull_backend $1 $2 $3
        pull_frontend $1 $2 $4
        build_backend $1 $2 $3
        build_frontend $1 $2 $4
        post_build_qa1a $1 $2
        deb_package $1 $2 
        copy_to_repo $1 $2
        latest $1 $2

    fi
    if [ $2 == "qa1b" ]; then
        mk_dir_build $1 $2
        pull_backend $1 $2 $3
        pull_frontend $1 $2 $4
        build_backend $1 $2 $3
        build_frontend $1 $2 $4
        post_build_qa1b $1 $2
        deb_package $1 $2
        copy_to_repo $1 $2
        latest $1 $2

    fi
    if [ $2 == "qa" ]; then
        mk_dir_build $1 $2
        pull_backend $1 $2 $3
        pull_frontend $1 $2 $4
        build_backend $1 $2 $3
        build_frontend $1 $2 $4
        post_build_qa $1 $2
        deb_package $1 $2
        copy_to_repo $1 $2
        latest $1 $2

    fi
    if [ $2 == "dev" ]; then
        mk_dir_build $1 $2
        pull_backend $1 $2 $3
        pull_frontend $1 $2 $4
        build_backend $1 $2 $3
        build_frontend $1 $2 $4
        post_build_dev $1 $2
        deb_package $1 $2
        copy_to_repo $1 $2
        latest $1 $2

    fi

    if [ $2 == "va" ]; then
        mk_dir_build $1 $2
        pull_backend $1 $2 $3
        pull_frontend $1 $2 $4
        build_backend $1 $2 $3
        build_frontend $1 $2 $4
        post_build_va $1 $2
        deb_package $1 $2
        copy_to_repo $1 $2
        latest $1 $2

    fi
else
    echo ""
    echo -e "\n\nUsage: $0 {branch name} {ENV: prod|qa|qa1a|qa1b|va} {master} {master}\n\n"
    echo -e "ex: $0 identity-1.1 qa backend:branch frontend:branch data:branch security:branch \n\n"
    echo ""
fi
