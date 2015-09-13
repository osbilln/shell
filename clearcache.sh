#!/bin/sh


## 0 * * * * /usr/bin/clearcache.sh
sync; echo 3 > /proc/sys/vm/drop_caches
