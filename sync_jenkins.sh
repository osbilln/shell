#!/bin/bash -e
##-------------------------------------------------------------------
## File : sync_jenkins.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description : Sync jenkins jobs configurations to chef cookbook
## --
## Created : <2014-08-31>
## Updated: Time-stamp: <2014-09-24 00:30:10>
##-------------------------------------------------------------------
chef_dir=${1:-"/home/denny/chef"}
chef_jenkins_jobs="$chef_dir/cookbooks/fluig-jenkins/templates/default/jenkins_jobs"
cd /var/lib/jenkins/jobs
for f in `find . -name "config.xml"`;
do
    job_name=$(basename $(dirname $f))
    mkdir -p $chef_jenkins_jobs/$job_name
    sudo chmod 777 $chef_jenkins_jobs/$job_name
    echo "cp $f $chef_jenkins_jobs/$job_name/"
    sudo cp $f $chef_jenkins_jobs/$job_name/
done
## File : sync_jenkins.sh ends
