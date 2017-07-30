#!/bin/bash


if [ $# != 3 ]
then
  echo "Arg 1 must be a Package Name"
  echo "Arg 2 must be a Package Version"
  echo "Arg 1 must be a Package Path"
  echo "USAGE: $0 $1 $2 $3"
  exit 1
 else
  PACKAGE_NAME=$1
  PACKAGE_VER=$2
  PACKAGE_PATH=$3
fi

/usr/bin/fpm -s dir -t deb -n $PACKAGE_NAME  -v $PACKAGE_VER $PACKAGE_PATH
