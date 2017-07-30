#!/bin/sh
### BEGIN INIT INFO
# Provides:          scsitools-pre
# Required-Start:    mountdevsubfs
# Required-Stop:
# X-Start-Before:    checkroot
# Default-Start:     S
# Default-Stop:
# Short-Description: Create aliases for SCSI devices under /dev/scsi
### END INIT INFO
#
# This script is run early at boot time (before S10checkroot.sh), so / is not
# yet writable.  Therefore it is needed to set up a ramdisk for /dev/scsi.
# The ramdisk will be removed later, after / has been remounted rw and swap
# activated (see scsitools.sh).
#
# Written by Eric Delaunay <delaunay@debian.org> based on sources found in
# scsidev 2.10 from Kurt Garloff <garloff@suse.de>.
#
# Licensed under GPL.

. /etc/default/rcS

scsidevrw=0	    # is /dev/scsi writable at boot time?
needscsidev=0	    # is scsidev needed at all?


# if no mount points on /dev/scsi in /etc/fstab, scsidev might be not needed
# NB: does not work with devfs
if [ ! -e /dev/.devfsd ]; then
    if grep -q '^/dev/scsi' /etc/fstab; then
	needscsidev=1
    fi
fi

# check for writable /dev/scsi
if [ $needscsidev -eq 1 ]; then
    : 2> /dev/null > /dev/scsi/__try || true
    if [ -f /dev/scsi/__try ]; then
	scsidevrw=1
	rm -f /dev/scsi/__try
    fi
fi

case "$1" in
start)
    if [ -x /sbin/scsidev -a "$needscsidev" = 1 ]; then
	if [ "$scsidevrw" = 0 ]; then
	    echo "Setting up SCSI devices (first part)..."
	    # /dev is not writable, setup a small ramdisk (128kB)
	    # (ignore all errors in case there is no ramdisk support compiled
	    # in the kernel).
	    dd if=/dev/zero of=/dev/ram3 bs=1024 count=128 > /dev/null 2>&1
	    mke2fs -q -F -i1024 -g4096 /dev/ram3 128 > /dev/null 2>&1
	    mount -n -t ext2 /dev/ram3 /dev/scsi > /dev/null 2>&1
	    if [ ! -d /dev/scsi/lost+found ]; then
		echo "Error creating ramdisk on /dev/scsi.  Is ramdisk supported by the kernel?"
	    fi
	else
	    echo "Setting up SCSI devices..."
	fi
	/sbin/scsidev -r -q
    fi
    ;;
reload | restart | force-reload | stop)
    echo "This script is not designed to work with <$0> argument."
    echo "Use /etc/init.d/scsitools.sh instead."
    exit 1
    ;;
*)
    echo "Usage: $0 {start|stop|restart|reload|force-reload}"
    exit 1
    ;;
esac

unset needscsidev scsidevrw

