#!/bin/bash -e
##-------------------------------------------------------------------
## File : build_iso_utility.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-14>
## Updated: Time-stamp: <2014-09-24 18:05:50>
##-------------------------------------------------------------------
. /usr/lib/fluig_devops_lib.sh

function copy_files_internal() {
    chroot_dir=${1?}
    files=${2?}

    src_list=($files)
    for f in ${src_list[*]}; do
        if [ -f $f ]; then
            /bin/cp $f $chroot_dir/$f
        else
            if [ -d $f ]; then
                [ ! -d chroot_dir/$f ] || rm -rf $chroot_dir/$f
                mkdir -p $chroot_dir/$f
                /bin/cp -r $f/* $chroot_dir/$f
            else
                log "Error: $f doesn't exist"
            fi
        fi
    done
}

function copy_files_to_image() {
    set -e
    log "Copy files to image"
    local chroot_dir=${1?}
    local download_dir=${2:-"/data/download"}
    mkdir -p $chroot_dir/$download_dir
    
    # Copy basic files
    mkdir -p $chroot_dir/etc
    copy_files_internal $chroot_dir "/etc/resolv.conf /etc/hosts"

    log "Copy common packages"
    mkdir -p $chroot_dir/$download_dir
    copy_files_internal $chroot_dir "/$download_dir/jdk-7u17-linux-x64.tar.gz /$download_dir/hornetq-2.2.14.tar /$download_dir/couchbase-server-enterprise_x86_64_2.1.0.deb"

    log "Copy frontend data"
    copy_files_internal $chroot_dir "/$download_dir/fluig_data.tar.gz"

    log "Copy /cloudpass/backend/build"
    mkdir -p $chroot_dir/cloudpass/backend/build/bin
    mkdir -p $chroot_dir/cloudpass/backend/build/config
    copy_files_internal $chroot_dir "/cloudpass/backend/build/bin /cloudpass/backend/build/config"

    log "Copy /cloudpass/backend/dist/VMManager.jar"
    mkdir -p $chroot_dir/cloudpass/backend/build/dist
    copy_files_internal $chroot_dir "/cloudpass/backend/build/dist/VMManager.jar"

    log "Copy java libraies"
    mkdir -p $chroot_dir/cloudpass/backend/build/lib
    copy_files_internal $chroot_dir "/cloudpass/backend/build/lib/"

    log "Update /etc/apt/sources.list.d"
    mkdir -p $chroot_dir/etc/apt/sources.list.d
    copy_files_internal $chroot_dir "/etc/apt/sources.list.d/couchbase.list /etc/apt/sources.list.d/fluig.list"

    # Hack chef credential
    mkdir -p $chroot_dir/etc/chef
    copy_files_internal $chroot_dir "/etc/chef/client.rb /etc/chef/client.pem /etc/chef/node.json"

    # copy sudoers
    mkdir -p $chroot_dir/etc/sudoers.d/
    copy_files_internal $chroot_dir "/etc/sudoers.d/nopasswd"

    # Hack SSL files
    mkdir -p $chroot_dir/etc/httpd/ssl
    [ -f /etc/httpd/ssl/DigiCertCA.crt ] || wget -O /etc/httpd/ssl/DigiCertCA.crt http://repo02.thecloudpass.com/fluig_share/common_packages/DigiCertCA.crt
    [ -f /etc/httpd/ssl/ssl.crt ] || wget -O /etc/httpd/ssl/ssl.crt http://repo02.thecloudpass.com/fluig_share/common_packages/ssl.crt
    [ -f /etc/httpd/ssl/ssl.key ] || wget -O /etc/httpd/ssl/ssl.key http://repo02.thecloudpass.com/fluig_share/common_packages/ssl.key

    copy_files_internal $chroot_dir "/etc/httpd/ssl/DigiCertCA.crt /etc/httpd/ssl/ssl.crt /etc/httpd/ssl/ssl.key"

    # TODO Deploy webapp
    mkdir -p $chroot_dir/etc/init.d/
    copy_files_internal $chroot_dir "/etc/init.d/init_webapp"
}


## File : build_iso_utility.sh ends
