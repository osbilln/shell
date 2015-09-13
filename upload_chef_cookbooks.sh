#!/bin/bash -e
##-------------------------------------------------------------------
## File : upload_chef_cookbooks.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-11>
## Updated: Time-stamp: <2014-09-22 15:39:57>
##-------------------------------------------------------------------
. $(dirname $0)/fluig_chef_utility.sh
working_dir=${1:-"/home/denny/chef"}
ensure_is_root

LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
# Note: since cookbook has dependencies, we need upload them in order
cookbooks="fluig-files fluig-basic-os fluig-dev-os build-iso common-server fluig-adsync fluig-apache fluig-backup fluig-buildkit fluig-couchbase fluig-crontab fluig-java fluig-jenkins fluig-keystore fluig-logrotate fluig-messaging fluig-nagios fluig-precheck fluig-postcheck fluig-initialize fluig-rest fluig-rmi fluig-search fluig-tomcat all-in-one"
cookbook_lists=($cookbooks)
for cookbook in ${cookbook_lists[*]}; do
    log "knife cookbook upload $cookbook"
    knife cookbook upload $cookbook
done
## File : upload_chef_cookbooks.sh ends
