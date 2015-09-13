#!/bin/bash -e
##-------------------------------------------------------------------
## File : nh_devops_lib.sh
# Author : Bill <billn@naehas.com>
## Description : Common shell script for devops
## --
## Created : <2014-08-10>
## Updated: Time-stamp: <2014-09-24 11:06:25>
##-------------------------------------------------------------------
# This shell library will be installed to /usr/lib/nh_devops_lib.sh by chef or manual copy
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function mk_dir()
{
    local dir=${1?}
    if [ ! -e $dir ]; then
        mkdir -p $dir
    fi
}

function is_port_listening()
{
    local port=${1?}
    lsof -i tcp:$port | grep LISTEN 1>/dev/null
}

function service_start () {
    local service_name=${1?}
    local wait_seconds=${2?}
    local monitor_tcp_port=${3?}

    log "start $service_name"
    /etc/init.d/$service_name start
    for((i=0; i< $wait_seconds; i++)); do
        if /etc/init.d/$service_name status | grep -v problem | grep -i 'is running' 1>/dev/null; then
            # Check port listening
            if [ -n "$monitor_tcp_port" ]; then
                if lsof -i tcp:$monitor_tcp_port | grep LISTEN 1>/dev/null; then
                    break
                fi
            else
                break
            fi
        else
            sleep 1
        fi
    done
}

function service_stop () {
    local service_name=${1?}
    local wait_seconds=${2?}

    log "stop $service_name"
    /etc/init.d/$service_name stop
    for((i=0; i< $wait_seconds; i++)); do
        if /etc/init.d/$service_name status | grep -i 'not running' 1>/dev/null; then
            break
        else
            sleep 1
        fi
    done
}

function service_status()
{
    service_name=${1?}
    log "Check $service_name"
    /etc/init.d/$service_name status
    echo ""
}

function tail_log_dir()
{
    log_dir=${1?}
    tail_count=${2:-3}
    log "Tail $log_dir"
    for f in `find $log_dir -name '*.log' -type f`; do
        echo -e "\n----------------<$f> start----------------";
        tail -n $tail_count "$f";
        echo -e "\n----------------<$f> end----------------\n";
    done
    echo ""
}

function wait_service_stop()
{
    local service_name=${1?}
    while [ "$(service_status "$service_name")" = "yes" ]; do
        # TODO add max seconds to wait
        sleep 1
    done;
}

function tar_dir()
{
    local dir=${1?}
    local tar_file=${2?}
    working_dir=`dirname $dir`
    cd $working_dir
    tar -zcf $tar_file `basename $dir`
}

function current_time()
{
    echo `date '+%Y-%m-%d-%H%M%S'`
}

function ensure_variable_isset() {
    var=${1?}
    message=${2:-"parameter name should be given"}
    # TODO support sudo, without source
    if [ -z "$var" ]; then
        echo "Error: Certain variable($message) is not set"
        exit 1
    fi
}

function ensure_is_root() {
    # Make sure only root can run our script
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root." 1>&2
        exit 1
    fi
}

function request_url_post() {
    url=${1?}
    data=${2?}
    header=${3:-""}
    if [ `uname` == "Darwin" ]; then
        data=$(echo "$data" | sed "s/\'/\\\\\"/g")
    else
        data=$(echo "$data" | sed "s/'/\\\\\"/g")
    fi;
    if [ "$header" = "" ]; then
        command="curl -d \"$data\" \"$url\""
    else
        command="curl $header -d \"$data\" \"$url\""
    fi;
    
    echo -e "\n$command"
    eval "$command"
    if [ $? -ne 0 ]; then
        echo "Error: fail to run $command"; exit -1
    fi
}

function request_url_get() {
    url=${1?}
    header=${2:-""}
    command="curl $header \"$url\""
    echo -e "\n$command"
    eval "$command"
    if [ $? -ne 0 ]; then
        echo "Error: fail to run $command"; exit -1
    fi
}
function umount_dir()
{
    local dir=${1?}

    if [ -d $dir ]; then
        fs_name=`stat --file-system --format=%T $dir`
        if [ "$fs_name" = "tmpfs" ] || [ "$fs_name" = "isofs" ]; then
            umount $dir
        fi
    fi
}

function install_chef_client() {
    set -e
    local chroot_dir=${1?}
    log "Install chef"
    chroot $chroot_dir wget -O /tmp/install.sh "https://www.opscode.com/chef/install.sh"
    chroot $chroot_dir bash /tmp/install.sh
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

## File : nh_devops_lib.sh ends
