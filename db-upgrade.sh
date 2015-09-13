#!/bin/bash

JAVA_HOME=/opt/jdk
BIN="cloudpass/backend/build/bin"
if [ -e $BIN/upgrade_script.sh ]
  then
    $BIN/upgrade_script.sh
  else
   exit 1
fi
