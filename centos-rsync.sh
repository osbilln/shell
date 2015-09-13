#!/bin/sh
#
# set -x
CENTOS6="6.3"

# RSYNCROOT="rsync://mirrors.kernel.org/centos"
RSYNCROOT="rsync://mirrors.usc.edu/centos"
LOCKFILE="/var/lock/subsys/centos-rsync"
# FTPROOT="/var/ftp/pub/centos"
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
    echo " ======== `date` ==========="
    /usr/bin/rsync --progress -avSHPrt --exclude i386 --exclude "SRPMS" --exclude "isos" --exclude "drpms" $RSYNCROOT/$CENTOS6/ $FTPROOT/$CENTOS6/ >> /var/log/centos-rsync.log
    chown -R root:root $FTPROOT/
    rm -f $LOCKFILE
else
    echo "Target directory $FTPROOT does not exist."
fi
