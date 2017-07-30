#!/bin/bash

cd /home
if [ ! -d ad.naehas.com ]; then
   mkdir ad.naehas.com
fi

homedir=`find -maxdepth 1 -type d | awk -F"./" '{print $2}'`

for dir in `echo $homedir`
  do
  if [ ! -L ${dir}\@ad.naehas.com ];then
    echo "Creating link for $dir" 
    ln -sf $dir ${dir}\@ad.naehas.com
  fi
done