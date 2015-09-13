#!/bin/bash -e
##-------------------------------------------------------------------
## File : utility.sh
## Author : Bill Nguyen <billn@naehas.com>
## Description :
## --
## Created : <2015-03-02>
## Updated: Time-stamp: <2015-03-02 13:58:08>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
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

function curl_head_200()
{
    url=${1?}
    log "curl -I $url"
    (sudo curl -I "$url" 2>&1 | grep '200 OK') 1>/dev/null
    if [ $? -ne 0 ]; then
        has_error=true
        log "Error: $url doesn't return 200"
    fi;
}

function curl_head_403()
{
    url=${1?}
    log "curl -I $url"
    (sudo curl -I "$url" 2>&1 | grep '403 Forbidden') 1>/dev/null
    if [ $? -ne 0 ]; then
        has_error=true
        log "Error: Fail to visit $url properly"
    fi;
}

function curl_check_output()
{
    url=${1?}
    pattern=${2?}
    log "curl '$url' 2>/dev/null | grep -v '$pattern' | wc -l"
    # note: below command won't detect curl failure, say 500 error
    output=$(curl "$url" 2>/dev/null | grep -v "$pattern" | wc -l)
    if [ $output -ne 0 ]; then
        has_error=true
        log "Error: Fail to visit $url properly"
    fi;
}

function port_listening()
{
    port=${1?}
    log "lsof -i tcp:$port | grep LISTEN"
    (sudo lsof -i tcp:$port | grep LISTEN) 1>/dev/null
    if [ $? -ne 0 ]; then
        has_error=true
        log "Error: port is not listening"
    fi;
}

function ps_process()
{
    process_regex=${1?}
    log "ps aux | grep $process_regex"
    (sudo ps aux | grep $process_regex | grep -v grep) 1>/dev/null
    if [ $? -ne 0 ]; then
        has_error=true
        log "Error: process for given pattern is not running"
    fi;
}

function cpu_load()
{
    load_threshold=${1?}
    log "cat /proc/loadavg | awk -F' ' '{print $1}'"
    loadavg=$(cat /proc/loadavg | awk -F' ' '{print $1}')
    result=$(echo "$loadavg >= $load_threshold" | bc)
    if [ $result -gt $load_threshold ]; then
        has_error=true
        log "Error: CPU overload. loadavg is $loadavg, which is above $load_threshold"
    fi;
}

function memory_available()
{
    memory_threshold=${1?}
    log "free -ml | grep 'buffers/cache' | awk -F' ' '{print $4}'"
    memory_free=$(free -ml | grep 'buffers/cache' | awk -F' ' '{print $4}')
    if [ $memory_free -lt $memory_threshold ]; then
        has_error=true
        log "Error: Low memory. Free memory is $memory_free MB, which is lower than $memory_threshold MB"
    fi;
}

function rootfs_disk_available()
{
    disk_threshold=${1?}
    log "df | grep ' /$' | awk -F' ' '{print $4}'"
    disk_free=$(df | grep ' /$' | awk -F' ' '{print $4}')
    if [ $disk_free -lt $disk_threshold ]; then
        has_error=true
        log "Error: Low disk for rootfs. Free disk is $disk_free KB, which is lower than $disk_threshold KB"
    fi;
}

## File : utility.sh ends
