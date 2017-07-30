#!/bin/bash -e
##-------------------------------------------------------------------
## File : install_chef_client.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-08-04>
## Updated: Time-stamp: <2014-09-11 14:48:18>
##-------------------------------------------------------------------
######################## Helper functions ############################
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
        echo "ERROR: Not supported OS"
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
        wget -O /tmp/opscode-keyring.gpg http://repo02.thecloudpass.com/fluig_share/common_packages/opscode-keyring.gpg
        /bin/cp -r /tmp/opscode-keyring.gpg /etc/apt/trusted.gpg.d/

        log "apt-get update"
        apt-get update

        log "install chef client"
        apt-get install opscode-keyring -y
    fi;
}
#######################################################################
function install_chef_client()
{
    set -e

    ubuntu_conf_apt_source
    apt-get install -y --force-yes build-essential
    apt-get install -y --force-yes ruby1.9.1
    apt-get install -y --force-yes ruby1.9.1-dev
    log "make sure ruby --version >=1.9.1"
    if [ -f /usr/bin/ruby1.9.1 ]; then
        rm -rf /usr/bin/ruby && ln -s /usr/bin/ruby1.9.1 /usr/bin/ruby
    else
        log "Error: ruby version should be >= 1.9.1"
        exit 1
    fi

    log "Install chef client"
    which chef-client 1>/dev/null || curl -L "https://www.opscode.com/chef/install.sh" | sudo bash -s -- -p
    $(gem list | grep ruby-shadow 1>/dev/null) || gem install ruby-shadow
}

function conf_chef_key()
{
    set -e
    node_name=${1:-'test.dennyzhang.com'}
    chef_server_url=${2:-'https://chef.fluigidentity.com'}

    #log "TODO manually create a new client in chef gui"
    #log "TODO Download /etc/chef/client.pem from chef gui"
    mkdir -p /etc/chef
    log "Configure /etc/chef/client.rb"
    cat > /etc/chef/client.rb <<EOF
log_level                :info
log_location             STDOUT
node_name                '$node_name'
client_key               '/etc/chef/client.pem'
chef_server_url          '$chef_server_url'
cache_type               'BasicFile'
cache_options( :path => '/etc/chef/checksums' )
EOF
}

ensure_is_root

node_name=${1:-"test.dennyzhang.com"}
chef_server_url=${2:-"https://chef.fluigidentity.com/"}

log "chef client: $client_name"
install_chef_client
conf_chef_key "$node_name" "$chef_server_url"

log "TODO Create file manually: /etc/chef/client.pem"
log "Try: chef-client"

# chef-client

log "install_chef_client.sh ends"
## File : install_chef_client.sh ends

