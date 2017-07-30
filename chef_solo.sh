#!/bin/bash -e
##-------------------------------------------------------------------
## File : chef_solo.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-08>
## Updated: Time-stamp: <2014-09-08 15:01:59>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function os_release() {
    set -e
    distributor_id=$(lsb_release -a 2>/dev/null | grep 'Distributor ID' | awk -F":\t" '{print $2}')
    if [ "$distributor_id" == "RedHatEnterpriseServer" ]; then
        echo "redhat"
    elif [ "$distributor_id" == "Ubuntu" ]; then
        echo "ubuntu"
    else
        echo "ERROR: Not supported OS"
    fi
}

function ensure_is_root() {
    # Make sure only root can run our script
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root." 1>&2
        exit 1
    fi
}

working_dir=${1:-"/home/denny"}

ensure_is_root

os_version=$(os_release)
if [ "$os_version" == "ubuntu" ]; then
    apt-get install -y ssh git
elif [ "$os_version" == "redhat" ]; then
    yum install -y ssh git
else
    log "Error: Not supported version"
fi

log "Git checkout code"
mkdir -p $working_dir && cd $working_dir
git clone https://github.com/TOTVS/chef.git

cd $working_dir/chef && git checkout chef-2.0

log "Install basic chef tools"
sudo $working_dir/chef/cmd/install_chef_solo.sh

log "Preparation of chef solo is done"
## File : chef_solo.sh ends
