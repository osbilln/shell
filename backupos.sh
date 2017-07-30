#!/bin/bash


if [ #$ -ne 1 ]; then
  echo " Usage: ./backupos.sh proddb8
fi
export SRCDIR="/folder/path"
export DESTDIR="$1"
rsync -aAXv --exclude={"/data/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} d8:/home $DESTDIR
