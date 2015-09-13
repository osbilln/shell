#!/bin/bash -e
##-------------------------------------------------------------------
## File : build_livecd_redhat.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-14>
## Updated: Time-stamp: <2014-09-26 14:09:56>
##-------------------------------------------------------------------
. /usr/lib/fluig_devops_lib.sh
. /opt/fluig_build_iso/build_iso_utility.sh

working_dir=${1:-"/home/denny/livecd/work/"}
############################################################################

# Make sure the script is run in right OS
if [[ "$(os_release)" != "redhat" ]]; then
    echo "Error: This script can only run in Redhat 6.5." 1>&2
    exit 1
fi

dst_iso="$working_dir/totvs-redhat-6.5.iso"

# TODO: make sure current OS is redhat/CentOS

log "Install epel repo"
if ! rpm -q epel-release 1>/dev/null; then
    wget -O $working_dir/epel-release-6-8.noarch.rpm http://mirror-fpt-telecom.fpt.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
    rpm -ivh $working_dir/epel-release-6-8.noarch.rpm
fi

log "Install necessary packages"
yum install -y livecd-tools pyliblzma

log "Create liveCD"
[ -d $working_dir ] || mkdir -p  $working_dir
cd $working_dir

kickstart_dir=$working_dir/spin-kickstarts
if [ ! -d $kickstart_dir ]; then
    log "git clone spin-kickstarts"
    git clone https://github.com/imcleod/spin-kickstarts
fi

cd spin-kickstarts

LANG=C livecd-creator -c ./fedora-livecd-desktop.ks -f RHEL6_LiveCD
## File : build_livecd_redhat.sh ends
