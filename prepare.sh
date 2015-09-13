#!/bin/bash

#  prepare.sh
#  FBScreenShare
#
#  Created by Ivan Shulev on 6/3/13.
#  Copyright (c) 2013 FuzeBox. All rights reserved.


DEPENDENCIES_DIR_NAME="dependencies"

SCRIPT_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIR_PATH="$(pwd)"

cd "$SCRIPT_DIR_PATH"

source ./common_scripts/set_common_variables.sh
source ./common_scripts/update_functions.sh

CLEAN=$1

if [ -z "$CLEAN" ]; then
    CLEAN="do_not_clean"
fi

clean()
{
    removeDir "$DEPENDENCIES_DIR_NAME/boost_ios"
    removeDir "$DEPENDENCIES_DIR_NAME/ipp"
    removeDir "$DEPENDENCIES_DIR_NAME/libijg"
}

main()
{
    if [ $CLEAN == "clean" ]; then
        clean
    fi

    provisionDir $TEMP_DIR_NAME

    provision "$BASE_URL/boost_ios" "boost_ios.tar.gz" "$DEPENDENCIES_DIR_NAME" "boost_ios"
    provision "$BASE_URL/ipp_mac" "ipp_mac_1.tar.gz" "$DEPENDENCIES_DIR_NAME" "ipp"
    provision "$BASE_URL/libijg_mac" "libijg_mac_1.tar.gz" "$DEPENDENCIES_DIR_NAME" "libijg"
}

main

cd "$CURRENT_DIR_PATH"
