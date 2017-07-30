#!/bin/bash -e
##-------------------------------------------------------------------
## File : build_livecd_ubuntu.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-14>
## Updated: Time-stamp: <2014-09-26 14:09:34>
##-------------------------------------------------------------------
. /usr/lib/fluig_devops_lib.sh
. /opt/fluig_build_iso/build_iso_utility.sh

working_dir=${1:-"/home/denny/livecd/work/"}
fetch_iso_url=${2:-"http://releases.ubuntu.com/12.04/ubuntu-12.04.4-desktop-amd64.iso"}

############################################################################
function original_ubuntu_iso() {
    local working_dir=${1?}
    local short_iso_filename=$(basename $fetch_iso_url)
    echo "$working_dir/../$short_iso_filename"
}

function livecd_clean_up() {
    umount_dir $working_dir/mnt
    umount_dir $working_dir/edit/dev
}

function customize_ubuntu_image() {
    set -e
    log "Customize Image"
    local chroot_dir=${1?}
    local download_dir=${2:-"/data/download"}
    install_chef_client $chroot_dir

    # install ubuntu repo key for couchbase
    chroot $chroot_dir bash -c "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A3FAA648D9223EDA"

    log "apt-get update"
    chroot $chroot_dir bash -c "apt-get update" 1>/dev/null

    log "Install packages. This may take ~30 seconds."
    packages_install_list="aptitude curl ssh tree unzip tmux"
    for package in ${packages_install_list[*]}; do
        chroot $chroot_dir bash -c "apt-get install -y $package" 1>/dev/null
    done

    log "Remove useless package. This may take ~30 seconds."
    #packages_remove_list="libreoffice-core thunderbird libreoffice-common libreoffice-writer libreoffice-help-en-us libreoffice-calc libreoffice-draw apparmor aspell aspell-en firefox firefox-locale-en firefox-locale-zh-hans ftp"
    packages_remove_list="firefox"
    for package in ${packages_remove_list[*]}; do
        chroot $chroot_dir bash -c "aptitude purge -y $package" 1>/dev/null
    done

    log "Deploy jdk manually"
    chroot $chroot_dir bash -c "cd $download_dir && tar -xf jdk-7u17-linux-x64.tar.gz && ln -s /data/download/jdk1.7.0_17 /opt/jdk"

    log "Deploy and enable webapp"
    chroot $chroot_dir bash -c "update-rc.d init_webapp defaults"
    chroot $chroot_dir bash -c "update-rc.d init_webapp enable"
}

# How to build liveCD of ubuntu: http://customizeubuntu.com/ubuntu-livecd
# Note: above instruction only support desktop version of ubuntu, instead of server version

# Example: /home/denny/chef/cookbooks/build-iso/files/default/fluig_build_iso/build_livecd_ubuntu.sh /home/denny/livecd/work
# Example: /home/denny/chef/cookbooks/build-iso/files/default/fluig_build_iso/build_livecd_ubuntu.sh /home/denny/livecd/i386  http://releases.ubuntu.com/12.04/ubuntu-12.04.4-desktop-i386.iso

# Make sure the script is run in right OS
if [[ "$(os_release)" != "ubuntu" ]]; then
    echo "Error: This script can only run in ubuntu 12.04 OS." 1>&2
    exit 1
fi
# Make sure the script is run as a root
ensure_is_root
trap livecd_clean_up SIGHUP SIGINT SIGTERM 0

dst_iso="$working_dir/totvs-ubuntu-12.04.4-amd64.iso"
volume_id="TOTVS Ubuntu"

log "Install necessary packages"
which aptitude 1>/dev/null || apt-get install -y aptitude 1>/dev/null
aptitude install -y squashfs-tools genisoimage 1>/dev/null

rm -rf $working_dir && mkdir -p $working_dir
cd $working_dir
mkdir mnt

ubuntu_iso_full_path=$(original_ubuntu_iso $working_dir)
if [ ! -f $ubuntu_iso_full_path ]; then
    log "Download original ubuntu iso"
    wget -O  $ubuntu_iso_full_path $fetch_iso_url
fi
[ -d /etc/chef ] || mkdir -p /etc/chef
# TODO: Need manually copy
#    cp /etc/chef/client.rb /etc/chef/client.pem /etc/chef/node.json
#    cp /home/denny/fluig_share/version_1.3.3/fluig_data/fluig_data.tar.gz /$download_dir/fluig_data.tar.gz

# mount mnt
log "Mount iso and extract content. This may takes ~30 seconds"
mount -o loop $(original_ubuntu_iso $working_dir) mnt
mkdir extract-cd
rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd

# unsquashfs
unsquashfs mnt/casper/filesystem.squashfs
mv squashfs-root edit

copy_files_to_image $working_dir/edit

log "Prepare and chroot"
mount --bind /dev/ edit/dev
chroot edit mount -t proc none /proc
chroot edit mount -t sysfs none /sys
chroot edit mount -t devpts none /dev/pts

# chroot edit export HOME=/root
# chroot edit export LC_ALL=C

customize_ubuntu_image $working_dir/edit

log "Clean up and umount filesystem"
chroot edit apt-get install -y aptitude
chroot edit aptitude clean
chroot edit rm -rf /tmp/* ~/.bash_history
# TODO
# chroot edit rm -rf /etc/resolv.conf
# chroot edit rm -rf /var/lib/dbus/machine-id
# chroot edit rm -rf /sbin/initctl
# chroot edit dpkg-divert --rename --remove /sbin/initctl

chroot edit umount /proc
chroot edit umount /sys
chroot edit umount /dev/pts
umount edit/dev

log "Regenerate Manifest"
chmod +w extract-cd/casper/filesystem.manifest
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop # TODO
sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop # TODO

log "Compress to SquashFS Filesystem. This shall take several minutes"
[ ! -f extract-cd/casper/filesystem.squashfs ] || rm extract-cd/casper/filesystem.squashfs
mksquashfs edit extract-cd/casper/filesystem.squashfs

log "Update md5sum"
cd extract-cd
rm md5sum.txt
find -type f -print0 | xargs -0 md5sum | grep -v isolinux/boot.cat | tee md5sum.txt

log "Create ISO image"
mkisofs -r -D -V "$volume_id" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $dst_iso .
log "Build process completed: image can be found in $dst_iso."
## File : build_livecd_ubuntu.sh ends