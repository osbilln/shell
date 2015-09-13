#!/bin/sh

OLD_DIR=`pwd`
SCRIPT_DIR=`dirname $0`

find $1 -name '*.csv' -exec echo Stripping {} \; -exec $SCRIPT_DIR/deleteCsvColumns.py {} 'Segment Name' 'record number' 'naehasid' 'naehaslistid' 'audit flag' 'segmentname' 'recordnumber' 'auditflag' \; 
