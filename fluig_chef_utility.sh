#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_chef_utility.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-08-20>
## Updated: Time-stamp: <2014-09-20 01:32:08>
##-------------------------------------------------------------------
export PATH=$PATH:/usr/local/bin

function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function ensure_is_root() {
    # Make sure only root can run our script
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root." 1>&2
        exit 1
    fi
}

function os_release() {
    set -e
    distributor_id=$(lsb_release -a 2>/dev/null | grep 'Distributor ID' | awk -F":\t" '{print $2}')
    if [ "$distributor_id" == "RedHatEnterpriseServer" ]; then
        echo "redhat"
    elif [ "$distributor_id" == "Ubuntu" ]; then
        echo "ubuntu"
    else
        if grep CentOS /etc/issue 1>/dev/null; then
            echo "centos"
        else
            echo "ERROR: Not supported OS"
        fi
    fi
}

function ubuntu_conf_apt_source()
{
    log "Configure apt-source"
    which add-apt-key 1>/dev/null || apt-get install add-apt-key -y

    if [ ! -f /etc/apt/sources.list.d/opscode.list ]; then
        # TODO: code is not re-entrant
        log "Add apt sources"
        echo "deb http://apt.opscode.com/ precise-0.10 main" > /etc/apt/sources.list.d/opscode.list

        log "Install the GPG key for the new repo"
        /bin/cp -r $(dirname $0)/opscode-keyring.gpg /etc/apt/trusted.gpg.d/

        log "apt-get update"
        apt-get update

        log "install chef client"
        apt-get install opscode-keyring -y
    fi;
}

## File : fluig_chef_utility.sh ends
