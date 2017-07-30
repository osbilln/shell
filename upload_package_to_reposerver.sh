#!/bin/bash -e
##-------------------------------------------------------------------
## File : upload_package_to_reposerver.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-08-31>
## Updated: Time-stamp: <2014-09-01 21:04:06>
##-------------------------------------------------------------------
branch_name=${1:-"master"}
working_dir=${2:-"/opt/jenkins/code"}
code_dir="$working_dir/$branch_name"

# TODO: Upload built packages to repo server

############################# Built Packages #############################
# $code_dir/backend/service/adsync/target/adsync-1.0.jar
# $code_dir/backend/service/keystore/target/keystore-1.0.jar
# $code_dir/backend/service/pending-job-agent/target/pending-job-agent-1.0.jar
# $code_dir/backend/service/rest-client/target/rest-client-1.0.jar
# $code_dir/backend/service/rest/target/rest-1.0.jar
# $code_dir/backend/service/scim-client/target/scim-client-1.0.jar
# $code_dir/backend/service/search/target/search-1.0.jar

# $code_dir/frontend/idm-cloudpass/target/cloudpass-0.1.war

############################## Repo server ##############################
# fluig_packages
# ./fluig_share/
# ├── common_packages
# │   ├── couchbase-server-enterprise_x86_64_2.1.0.deb
# │   ├── hornetq-2.2.14.tar
# │   ├── hornetq.tar
# │   └── jdk-7u17-linux-x64.tar.gz
# ├── fluig_java_lib
# │   ├── ST4-4.0.7.jar
# │   ├── activation-1.1.jar
# ...
# ...
# │   ├── xmltooling-1.4.0.jar
# │   └── xmlunit-1.3.jar
# └── fluig_packages
#     ├── ADSync.jar
#     ├── DownloadGlobalApps.jar
#     ├── KeystoreServerStart.jar
#     ├── PendingAgent.jar
#     ├── RandomScripts.jar
#     ├── Search.jar
#     ├── ServerStart.jar
#     ├── ServerStop.jar
#     ├── SyncGlobalApps.jar
#     ├── UpgradeScript.jar
#     ├── VABuildScript.jar
#     ├── VAPopulateScript.jar
#     ├── cloudpass.war
#     ├── rest-client-1.0.jar
#     ├── rest.jar
#     └── scim-client-1.0.jar

## File : upload_package_to_reposerver.sh ends
