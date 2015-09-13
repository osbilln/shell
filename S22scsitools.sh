#!/bin/sh
### BEGIN INIT INFO
# Provides:          scsitools
# Required-Start:    checkroot
# Required-Stop:
# X-Start-Before:    checkfs
# Default-Start:     S
# Default-Stop:
# Short-Description: Create aliases for SCSI devices under /dev/scsi
### END INIT INFO
#
# This is the second part of populating /dev/scsi.  Now / is writable, so
# remove the ramdisk and recreate the tree.
# When used with restart/force-reload argument, also rescan the SCSI bus to be
# sure the contents of /dev/scsi is in sync with accessible hardware.
#
# Written by Eric Delaunay <delaunay@debian.org> based on sources found in
# scsidev 2.10 from Kurt Garloff <garloff@suse.de>.
#
# Licensed under GPL.


. /etc/default/rcS

scsidevrw=0	    # is /dev/scsi writable at boot time?
needscsidev=0	    # is scsidev needed at all?
swapdev=0	    # is there swap device on /dev/scsi/... ?


# set needscsidev to 1 if /dev/scsi is referenced in /etc/fstab and set
# scsidevrw to 1 if /dev/scsi is a ramdisk (mounted from scsitools-pre.sh)
if [ ! -e /dev/.devfsd ]; then
    if grep -q '^/dev/scsi' /etc/fstab; then
	needscsidev=1
	if [ ! -d /dev/scsi/lost+found ]; then
	    scsidevrw=1
	fi
    fi
fi

case "$1" in
start)
    # if running from rcS, needscsidev & scsidevrw are already set by
    # scsitools-pre.sh to either 0 or 1.
    if [ -x /sbin/scsidev -a "$needscsidev" = 1 -a "$scsidevrw" = 0 ]; then
	# no need to rerun scsidev if previously done on a writable fs by
	# scsitools-pre.sh, otherwise...
	echo "Setting up SCSI devices (second part)..."
	# disable swap in case it is using a device under /dev/scsi
	# (/dev/scsi/swapdev used to be living on a ramdisk that have to be
	# destroyed)
	if grep -q '^/dev/scsi/' /proc/swaps; then
	    swapoff -a
	    swapdev=1
	fi
	# if using a ramdisk, free it first
	# (test is always true except when no support for ramdisk in kernel)
	if grep -q "/dev/ram3 .*/dev/scsi" /proc/mounts; then
	    umount -n /dev/scsi
	    blockdev --flushbufs /dev/ram3
	fi
	/sbin/scsidev -r -q
	# execute swapon again, in case we want to swap to another device
	# residing out of the boot disk.
	if [ $swapdev = 1 ]; then
	    swapon -a
	fi
    fi
    ;;
restart | force-reload)
    if [ -x /sbin/scsidev -a "$needscsidev" = 1 ]; then
	echo "Setting up SCSI devices..."
	# rescan the SCSI bus first
	/sbin/rescan-scsi-bus.sh -r -w
	# then fills /dev/scsi again according to detected devices
	/sbin/scsidev -r -q
    fi
    ;;
reload)
    if [ -x /sbin/scsidev -a "$needscsidev" = 1 ]; then
	echo "Setting up SCSI devices..."
	# only sets up /dev/scsi contents again
	/sbin/scsidev -r -q
    fi
    ;;
stop)
    # nothing to stop here.
    ;;
*)
    echo "Usage: $0 {start|stop|restart|reload|force-reload}"
    exit 1
    ;;
esac

unset needscsidev scsidevrw

