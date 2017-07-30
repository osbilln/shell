#!/bin/bash
# 
# File:         cf-list.sh
#
# Written by:   Tim Galyean
# Date:         8/4/2010
#
##################################################
 
USER="${1}"
APIKEY="${2}"
DEBUG="${3}"
LOG="cflist.log"
 
function f_exec() {
    if [ "${DEBUG}" = "1" ]; then
        # setting debug to 1 allows you to see full HTTP headers
        # using this option will redirect the output to cflist.log
        echo "redirecting verbose output to ${LOG}"
        CURL="curl -v -H"
        f_grabauthtoken 2>&1 > ${LOG}
        f_list 1>>${LOG} 2>&1
 
        # this url can be used to parse your containers and their contents
        # Example: curl -s -H "X-Auth-Token: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX" <container URL>/<container>
        echo "curl -s -H \"X-Auth-Token: ${STORAGETOKEN}\" $STORAGEURL"
    else
        # without using debug this script will just print your containers to stdout
        CURL="curl -s -H"
        f_grabauthtoken
        f_list
    fi
}
 
# Grab API Authentication Token, and Storage URL
function f_grabauthtoken() {
    # Establish initial authentication
    ${CURL} "X-Auth-User: ${USER}" -H "X-Auth-Key: ${APIKEY}" https://auth.api.rackspacecloud.com/v1.0 2>&1 | grep Storage | awk -F'<' '{print $2}'
 
    # Parse storage token to be used as an authentication key
    STORAGETOKEN=`curl -v -H "X-Auth-User: ${USER}" -H "X-Auth-Key: ${APIKEY}" https://auth.api.rackspacecloud.com/v1.0 2>&1 | \
    grep Storage | awk -F'<' '{print $2}' | grep Storage-Token | awk '{print $2}' | tr -d '\r'`
 
    # Parse the storage URL which will be the location of your containers
    STORAGEURL=`curl -v -H "X-Auth-User: ${USER}" -H "X-Auth-Key: ${APIKEY}" https://auth.api.rackspacecloud.com/v1.0 2>&1 | \
    grep Storage | awk -F'<' '{print $2}' | grep Storage-Url | awk '{print $2}'`
 
}   
 
# List Containers
function f_list() {
    if [ -n ${STORAGETOKEN} ]; then
        # This sends the API your token and storage url
        # the API will return your container listing
        ${CURL} "X-Auth-Token: ${STORAGETOKEN}" $STORAGEURL
    else
        echo "Please authenticate first"
    fi
}
 
# Usage instructions
function f_verify() {
    # basic usage instructions
    # to enable debugging use: ./cf-list.sh <username> <apikey> 1
    if [ -z "${USER}" ] || [ -z "${APIKEY}" ]; then
        echo "Usage: ./cf-list.sh <username> <apikey>"
    else
        f_exec
    fi
}
 
f_verify
