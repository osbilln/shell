#!/bin/bash -e
##-------------------------------------------------------------------
## File : tests.sh
## Author : filebat <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-07-17>
## Updated: Time-stamp: <2014-07-28 22:17:33>
##-------------------------------------------------------------------
PORT_GATEWAY=18100
SERVER_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
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
    echo ""
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
    echo ""
}

function integration_test () {
    log "Integration test"
    # read metric
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=system_availability_7days
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=system_availability_30days
    # request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=10alerts

    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=search_service_status
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=core_service_status
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=ad_service_status
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=appserver_service_status
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=rest_service_status
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=hornetq_service_status
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=couchbase_service_status
    request_url_get http://$SERVER_IP:$PORT_GATEWAY/metric?name=keystore_service_status

    # update metric
    #request_url_post http://$SERVER_IP:$PORT_GATEWAY/metric "name='metric1'&value='value1'"
}

function load_test () {
    log "Perform load test"
    ab -i -n 100 -c 5 http://$SERVER_IP:$PORT_GATEWAY/metric?name=system_availability_7days
    echo ""
}

fun_name=${1:-"integration_test"}
$fun_name

## File : tests.sh ends
