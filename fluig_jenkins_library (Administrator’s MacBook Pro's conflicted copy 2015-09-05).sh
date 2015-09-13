#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_jenkins_library.sh
## Author : Denny <denny.zhang@totvs.com>
## Description :
## --
## Created : <2014-08-30>
## Updated: Time-stamp: <2014-09-24 01:26:12>
##-------------------------------------------------------------------
#. /etc/profile
. /usr/lib/fluig_devops_lib.sh

######################### Helper functions  ###################################
function git_update_code()
{
    set -e
    local git_repo_url=${1?}
    local branch_name=${2?}
    local working_dir=${3?}
    log "Git update code for '$git_repo_url' to $working_dir, branch_name: $branch_name"
    # checkout code, if absent
    if [ ! -d $working_dir ]; then
        mkdir -p "$working_dir"
        cd $(dirname $working_dir)
        git clone $git_repo_url
    fi

    cd $working_dir
    git checkout $branch_name && git pull
}

BUILD_FRONTEND_LOCKFILE=/tmp/frontend.lock
function clean_up_frontend {
    echo "Delete lockfile, when building frontend task finish"
    if [ $repo_name = "frontend" ] && [ `cat $BUILD_FRONTEND_LOCKFILE` = "$$" ] ; then
	# Perform program exit housekeeping
	rm $BUILD_FRONTEND_LOCKFILE
	exit
    fi;
}
###############################################################################

function build_backend()
{
    set -e
    log "Build backend package"
    local working_dir=${1?}
    local branch_name=${2?}
    local code_dir="$working_dir/$branch_name"
    cd $code_dir/backend
    mvn clean install

    log "Generate backend packages"
}

function build_security()
{
    set -e
    log "Build security package"
    local working_dir=${1?}
    local branch_name=${2?}
    local code_dir="$working_dir/$branch_name"

    cd $code_dir/security/protocol/saml/

    git pull
    mvn clean install

    log "Generate security packages"
}

function build_frontend()
{
    set -e
    # Currently we can't run multiple frontend build tasks at the same time
    trap clean_up_frontend 0 SIGHUP SIGINT SIGTERM
    wait_seconds=10
    while [ -f $BUILD_FRONTEND_LOCKFILE ]; do
        echo "Detect parallel tasks of building frontend package, which is not supported. Wait for another $wait_seconds seconds."
        sleep $wait_seconds
    done
    echo $$ > $BUILD_FRONTEND_LOCKFILE

    log "Build frontend package"
    local working_dir=${1?}
    local branch_name=${2?}
    local code_dir="$working_dir/$branch_name"

    log "Copy files of backend to frontend"
    cp $code_dir/backend/idm-common/target/idm-common-1.0.jar $code_dir/frontend/idm-cloudpass/lib/
    cp $code_dir/backend/idm-common/libs/fang-oauth2-core-1.0.jar $code_dir/frontend/idm-cloudpass/lib/
    cp $code_dir/backend/idm-common-model/target/idm-common-model-1.0.jar $code_dir/frontend/idm-cloudpass/lib/

    log "Copy files of security to frontend"
    cp $code_dir/security/protocol/saml/target/saml-1.0.jar $code_dir/frontend/idm-cloudpass/lib/

    cd $code_dir/frontend/idm-cloudpass
    git pull
    grails clean
    grails refresh-dependencies
    grails compile
    grails war
    log "Generate packages of cloudpass*.war"
}
## File : fluig_jenkins_library.sh ends
