#!/bin/sh
#
set -x
CENTOS6="6"
RSYNCROOT="rsync://mirror.nexicom.net/Fedora-EPEL"
LOCKFILE="/var/lock/subsys/epel-rsync"
FTPROOT="/var/www/html/centos"

if [ -f $LOCKFILE ]; then
    echo "centos-rsync.sh is already running."
    exit 0
fi

if [ -d $FTPROOT ]; then
    touch $LOCKFILE

    echo "----------"
    echo "CentOS $CENTOS6"
    echo "----------"
#    /usr/bin/rsync --progress -avSHPrt --delete --exclude "local*" --exclude "SRPMS" --exclude "isos" --exclude "centosplus" --exclude "contrib" --exclude "fasttrack" --exclude "drpms" $RSYNCROOT/$CENTOS6/ $FTPROOT/$CENTOS6/
# cd /data/centos/6/updates && /usr/bin/rsync --progress -avSHPrt --delete --exclude i386 -exclude ppc64 --exclude "isos" --exclude "drpms" $RSYNCROOT/$CENTOS6/ .
   cd /data/centos/6/updates/ && rsync -avzt --exclude SRPMS --exclude i386 --exclude isos  --exclude i386 --exclude ppc64 rsync://mirror.nexicom.net/Fedora-EPEL/6/ . >> /var/log/centos_epel.log
    chown -R root:root $FTPROOT/
    rm -f $LOCKFILE
else
    echo "Target directory $FTPROOT does not exist."
fi
