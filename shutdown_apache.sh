#!/bin/bash -e
##-------------------------------------------------------------------
## File : shutdown_apache.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description : When some critical services are down, stop apache instance in the server
## --
## Created : <2014-08-03>
## Updated: Time-stamp: <2014-08-03 17:55:00>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

# TODO

## File : shutdown_apache.sh ends
