#!/bin/bash -e
##-------------------------------------------------------------------
## File : jenkins_build_package.sh
## Author : Denny <denny.zhang@totvs.com>
## Description :
## --
## Created : <2014-08-30>
## Updated: Time-stamp: <2014-09-25 17:34:04>
##-------------------------------------------------------------------
. /etc/profile
. /var/lib/jenkins/jenkins_scripts/fluig_jenkins_library.sh

# Example: 
#     bash -x ./jenkins_build_package.sh "backend" "master" "/opt/jenkins/code"
#     bash -x ./jenkins_build_package.sh "security" "master" "/opt/jenkins/code"
#     bash -x ./jenkins_build_package.sh "frontend" "master" "/opt/jenkins/code"

# Shell entrance
repo_name=${1?"repo name"}
branch_name=${2:-"master"}
working_dir=${3:-"/opt/jenkins/code"}

# read repo_name from conf file
if [ -f $branch_name ]; then
    branch_name=`cat $branch_name`
fi

case "$repo_name" in
    backend)
        git_update_code "git@github.com:TOTVS/backend.git" $branch_name $working_dir/$branch_name/backend
        build_backend "$working_dir" $branch_name
        ;;
    security)
        git_update_code "git@github.com:TOTVS/security.git" $branch_name $working_dir/$branch_name/security
        build_security "$working_dir" $branch_name
        ;;
    frontend)
        git_update_code "git@github.com:TOTVS/frontend.git" $branch_name $working_dir/$branch_name/frontend
        build_frontend "$working_dir" $branch_name
        ;;
    *)
        echo "ERROR: unsupported repo_name($repo_name)";
        exit 1
esac
## File : jenkins_build_package.sh ends
