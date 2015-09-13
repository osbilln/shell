#!/bin/bash -e
##-------------------------------------------------------------------
## File : test_service.sh
## Author : dennyzhang.com <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-06-15>
## Updated: Time-stamp: <2014-06-15 11:26:17>
##-------------------------------------------------------------------
. utility.sh

request_url_get http://127.0.0.1:$PORT_GATEWAY/test_server
echo ""
## File : test_service.sh ends
