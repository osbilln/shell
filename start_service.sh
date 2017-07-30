#!/bin/bash -e
##-------------------------------------------------------------------
## File : start_service.sh
## Author : dennyzhang.com <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-06-15>
## Updated: Time-stamp: <2014-06-15 11:25:07>
##-------------------------------------------------------------------
. $(dirname $0)/utility.sh
ensure_is_root

sudo lsof -i tcp:$PORT_GATEWAY || (cd ../code/ && nohup sudo python webserver.py &)

## File : start_service.sh ends
