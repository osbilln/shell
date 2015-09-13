#!/bin/bash -e
##-------------------------------------------------------------------
## File : install_chef_knife.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-08-04>
## Updated: Time-stamp: <2014-09-11 09:46:19>
##-------------------------------------------------------------------
. $(dirname $0)/fluig_chef_utility.sh
function conf_chef_knife()
{
    set -e
    log "Configure /root/.chef/knife.rb"

    mkdir -p /root/.chef/

    node_name=${1:-'adminclient.dennyzhang.com'}
    validation_client_name=${2:-'chef_admin'}
    chef_server_url=${3:-'https://chef.fluigidentity.com/'}
    cookbook_path=${4:-'/home/denny/chef/cookbooks/'}
    cat > /root/.chef/knife.rb << EOF
log_level                :info
log_location             STDOUT
node_name                '$node_name'
client_key               '/etc/chef/adminclient.pem'
validation_client_name   '$validation_client_name'
validation_key           '/etc/chef/validator.pem'
chef_server_url          '$chef_server_url'
syntax_check_cache_path  '/root/.chef/syntax_check_cache'
cookbook_path [ '$cookbook_path']
EOF

}


ensure_is_root
install_chef_workstation

node_name=${1:-""}
client_name=${2:-"chef_client_aio"}
chef_server_url=${3:-"https://chef.fluigidentity.com/"}

log "Install chef knife"
install_chef_client
conf_chef_key "$node_name" "$client_name" "$chef_server_url"
conf_chef_knife "$node_name" "$client_name" "$chef_server_url"

log "TODO Create file manually: /etc/chef/adminclient.pem"
log "TODO Create file manually: /etc/chef/validator.pem"
log "Try: knife client list"
## File : install_chef_knife.sh ends
