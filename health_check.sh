#!/bin/bash -e
##-------------------------------------------------------------------
## File : health_check.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-07-23 10:09:25>
##-------------------------------------------------------------------
. utility.sh

PORT_GATEWAY=18100
sudo lsof -i tcp:$PORT_GATEWAY || exit_error "Gateway service is not running"

## File : health_check.sh ends
