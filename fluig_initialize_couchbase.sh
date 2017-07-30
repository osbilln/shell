#!/bin/bash -e
##-------------------------------------------------------------------
## File : fluig_initialize_couchbase.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-15>
## Updated: Time-stamp: <2014-09-16 00:46:17>
##-------------------------------------------------------------------
. /etc/profile
function log() {
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function cb_init_cluster() {
    log "Init cluster of couchbase"
    local cb_admin_passwd=${1:-"password1234"}
    local cb_cluster_ramsize=${2:-1024}
    local cb_admin_name=${3:-"Administrator"}
    local cb_server=${4:-"localhost"}
    couchbase-cli cluster-init -c $cb_server -u $cb_admin_name -p $cb_admin_passwd \
        --cluster-init-username=$cb_admin_name --cluster-init-password=$cb_admin_passwd \
        --cluster-init-ramsize=$cb_cluster_ramsize
}

function cb_create_bucket() {
    local cb_admin_passwd=${1:-"password1234"}
    local cb_bucket_ramsize=${2:-512}
    local cb_bucket_name=${3:-"cloudpass"}
    local cb_admin_name=${4:-"Administrator"}
    local cb_bucket_type=${5:-"couchbase"}
    local cb_bucket_passwd=${6:-""}
    local cb_bucket_enable_flush=${7:-1}
    local cb_server=${8:-"localhost"}
    local cb_bucket_enable_index_replica=${9:-1}

    log "Create couchbase bucket of $cb_bucket_name"
    couchbase-cli bucket-create -c $cb_server -u $cb_admin_name -p $cb_admin_passwd \
       --bucket=$cb_bucket_name \
       --bucket-type=$cb_bucket_type \
       --bucket-password=$cb_bucket_passwd \
       --bucket-ramsize=$cb_bucket_ramsize \
       --enable-flush=$cb_bucket_enable_flush \
       --enable-index-replica=$cb_bucket_enable_index_replica
}

admin_passwd=${1?}
bucket_ramsize=${2?}
flagfile=${3?}

if [ -f $flagfile ]; then
    log "Error to initialize couchbase. $flagfile already exists, which means it's already initialized"
    exit 1
fi

cb_init_cluster $admin_passwd
cb_create_bucket $admin_passwd $bucket_ramsize

# When initialization is done, create a flagfile
touch $flagfile

## File : fluig_initialize_couchbase.sh ends
