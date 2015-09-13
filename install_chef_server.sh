#!/bin/bash -e
##-------------------------------------------------------------------
## File : install_chef_server.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-08-04>
## Updated: Time-stamp: <2014-09-11 09:34:25>
##-------------------------------------------------------------------
. $(dirname $0)/fluig_chef_utility.sh

function install_chef_server ()
{
    set -e
    log "Install chef server"
    if ! `which chef-server-ctl 1>/dev/null ` ; then
        working_dir=${1:-"/home"}
        cd "$working_dir"
        log "Download chef-server debian package"
        # TODO get package from local server, to speed up
        [ ! -f chef-server_11.0.10-1.ubuntu.12.04_amd64.deb ] \
            && wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.10-1.ubuntu.12.04_amd64.deb

        log "Install chef-server"
        dpkg -i chef-server*
    fi;
}

function configure_chef_server()
{
    set -e
    $(gem list | grep ruby-shadow 1>/dev/null) || gem install ruby-shadow
    # TODO: make the code re-entrant
    log "Configure chef-server"
    chef-server-ctl reconfigure
}

ensure_is_root
log "TODO change hostname fqdn manually: vim /etc/hostname"
hostname -f

install_chef_server "/home"

configure_chef_server

log "install_chef_server.sh ends"
## File : install_chef_server.sh ends
