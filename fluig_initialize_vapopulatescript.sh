#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_initialize_vapopulatescript.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-15>
## Updated: Time-stamp: <2014-09-25 13:20:50>
##-------------------------------------------------------------------
. /etc/profile
. /usr/lib/fluig_devops_lib.sh

ensure_is_root

# Example: fluig_initialize_vapopulatescript.sh /data/fluig_state/fluig_already_initialized /data/fluig_state/vapopulate_already_initialized
flagfile=${1?}
fluig_flag_file=${2?}
va_populate_dir=${3:-"/data/security"}
sleep_seconds=${4:-5}

# Check flagfile: /data/fluig_state/fluig_already_initialized
if [ ! -f $fluig_flag_file ]; then
    log "Error: VApopulateScript can only be triggered after fluig system is initialized"
    exit 1
fi

# Check flagfile: fluig_initialize_vapopulatescript.sh
if [ -f $flagfile ]; then
    log "Error to initialize VApopulateScript. $flagfile already exists, which means it's already initialized"
    exit 1
fi

java -jar /cloudpass/backend/build/dist/VAPopulateScript.jar $va_populate_dir

# When initialization is done, create a flagfile
touch $flagfile

## File : fluig_initialize_vapopulatescript.sh ends