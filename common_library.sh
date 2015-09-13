#!/bin/bash -e
##-------------------------------------------------------------------
## File : common_library.sh
## Author : Bill <bill.nguyen@totvs.com>, Denny <denny.zhang@totvs.com>
## Description :
## --
## Created : <2014-08-26>
## Updated: Time-stamp: <2014-08-26 15:39:41>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?} >> $LOG_FILE
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n" >> $LOG_FILE
}

function mk_dir()
{
    local dir=${1?}
    if [ ! -e $dir ]; then
        mkdir -p $dir
    fi
}

function check_error {
        if [ $? -ne 0 ] ; then
        exit -1
        fi
}

function gitpull {
  git add .
  git reset --hard 
  git pull
}

## File : common_library.sh ends
