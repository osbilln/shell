#!/bin/bash -e
##-------------------------------------------------------------------
## File : manage_virtualbox_vm.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-09-14>
## Updated: Time-stamp: <2014-09-16 21:48:51>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function ensure_is_root() {
    # Make sure only root can run our script
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This script must be run as root." 1>&2
        exit 1
    fi
}

function exists_vm(){
    VM=${1?'VM name'}
    if VBoxManage list vms | grep $VM; then
        return 0
    else
        return 1
    fi;
}

function is_vm_running() {
    VM=${1?'VM name'}
    if VBoxManage showvminfo $VM | grep 'State: \+running'; then
        return 0
    else
        return 1
    fi;
}

function destory_vm()
{
    VM=${1?'VM name'}
    log "destory_vm: $VM"
    sleep_seconds=${2:-3}
    if exists_vm "$VM"; then
        if is_vm_running $VM; then
            log "vm($VM) is running, poweroff it first"
            VBoxManage controlvm "$VM" poweroff
            sleep $sleep_seconds
        fi;
        log "destory vm: vm($VM)"
        VBoxManage unregistervm "$VM" --delete
    else
        log "Skip destory_vm, since the vm($VM) doesn't exists."
    fi;
}

function create_vm()
{
    log "create_virtualbox_vm"
    VM=${1?'VM name'}
    # Run 'VBoxManage list ostypes' to get a list of the OS types VirtualBox recognises using:
    media_iso=${2?'iso location'}
    memory_size=${3:-1024}
    disk_size=${4:-32768}
    hostonly_adapter=${5:-"vboxnet0"}

    #vboxdir=$(VBoxManage list systemproperties | awk -F: '/^Default.machine.folder/ { print $2 }')
    vdi_dir=${6:-"."}
    vdi_file="$vdi_dir/$VM.vdi"
    vm_rootdir=${7:-"/root/VirtualBox VMs"}
    OSTYPE=${8:-"Other_64"}

    vm_dir="$vm_rootdir/$VM"

    destory_vm "$VM"
    [[ -f "$vdi_file" ]] && (log "Error: $vdi_file exists"; exit -1)
    [[ -d "$vm_dir" ]] && (log "Error: $vm_dir exists"; exit -1)

    VBoxManage createvm --name "$VM" --ostype $OSTYPE --register
    VBoxManage modifyvm "$VM" --memory $memory_size --acpi on --boot1 dvd

    # Use NAT for the network
    VBoxManage modifyvm "$VM" --nic1 hostonly --hostonlyadapter1 $hostonly_adapter
    VBoxManage modifyvm "$VM" --nic2 NAT

    # set disk as SATA, and mount iso as IDE
    VBoxManage createhd --filename "$vdi_file" --size $disk_size

    VBoxManage storagectl "$VM" --name "SATA Controller" --add sata --controller IntelAHCI
    VBoxManage storageattach "$VM" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vdi_file"

    VBoxManage storagectl "$VM" --name "IDE Controller" --add ide
    VBoxManage storageattach "$VM" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$media_iso"

    VBoxManage modifyvm "$VM" --ioapic on
    VBoxManage modifyvm "$VM" --boot1 dvd --boot2 disk --boot3 none --boot4 none

    VBoxHeadless --startvm "$VM" &

    # TODO: more graceful
    sleep_seconds=10
    log "wait $sleep_seconds seconds to wait until the vm is up"
    sleep $sleep_seconds
}

# TODO: need to create a hostonly adapter naming vboxnet0 first in virtual box
# ./manage_virtualbox_vm.sh ubuntu_livecd ./ubuntu-12.04.4-amd64-custom.iso
vm_name=${1:-"galaxyio_vm1"}
iso_file=${2:-"/home/denny/testsuite-fsperf/jenkins/livecd-ansible/galaxyio.iso"}
memory_size=${3:-4096}
disk_size=${4:-32768}
create_vm $vm_name $iso_file $memory_size $disk_size

## File : manage_virtualbox_vm.sh ends
