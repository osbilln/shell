#!/bin/bash


FI_HOME=/cloudpass
BACKEND=$FI_HOME/backend

cd $BACKEND/build/config
        find . -name keystore.yml | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        # backup the file
        cp $f ${f}.local
        sed 's/address: \"127.0.0.1\"/address: \"172.20.16.20\"/g' $f > ${f}.1
        sed 's/remote: \"127.0.0.1\"/remote: \"172.20.16.14\"/g' $f.1 > ${f}.2
        mv ${f}.2 $f
        rm -rf ${f}.1 ${f}.local
    done

