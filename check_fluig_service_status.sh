#!/bin/bash -e
##-------------------------------------------------------------------
## File : check_fluig_service_status.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-07-23>
## Updated: Time-stamp: <2014-07-23 11:38:28>
##-------------------------------------------------------------------
# TODO

function check_service_search()
{
    # TODO
    return 0
}

function check_service_core()
{
    # TODO
    # Core services : apache, tomcat7, RMI, ADSync
    return 0
}

function check_service_ad()
{
    # TODO
    # AD services : RMI, ADSync, SmartSync, customer's AD Server
    return 0
}

function check_service_appserver()
{
    # TODO
    return 0
}

function check_service_rest()
{
    # TODO
    return 0
}

function check_service_hornetq()
{
    # TODO
    return 0
}

function check_service_couchbase()
{
    # TODO
    return 0
}

function check_service_keystore()
{
    # TODO
    return 0
}

service_name=${1?}
shift

# TODO remove code duplication, by generating function name automatically
case "$service_name" in
    search)
        check_service_search
        ;;
    core)
        check_service_core
        ;;
    ad)
        check_service_ad
        ;;
    appserver)
        check_service_appserver
        ;;
    rest)
        check_service_rest
        ;;
    couchbase)
        check_service_couchbase
        ;;
    keystore)
        check_service_keystore
        ;;
    *)
        echo $"Invalid service_name is given: $service_name"
        exit 2
esac
## File : check_fluig_service_status.sh ends
