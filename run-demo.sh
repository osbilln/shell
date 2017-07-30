#!/bin/sh

DEST_VM_NAME="chef-wordpress-demo"

VMS_DIR="$HOME/Documents/Virtual Machines.localized"
SOURCE_VM_DIRNAME="Chef Ubuntu Template.vmwarevm"
DEST_VM_DIRNAME="$DEST_VM_NAME.vmwarevm"

USERNAME=vmware
PASSWORD=vmware123

TEMPLATE_FILE=`pwd`/my-ubuntu.erb
RUN_LIST="recipe[wordpress]"


sudo killall vmware-vmx 2>/dev/null
rm -rf "$VMS_DIR/$DEST_VM_DIRNAME"
knife node delete -y $DEST_VM_NAME 2>/dev/null

knife client delete -y $DEST_VM_NAME
knife wsfusion create \
	--vm-name="$DEST_VM_NAME" \
	--vm-source-path="$VMS_DIR/$SOURCE_VM_DIRNAME" \
	--ssh-user=$USERNAME \
	--ssh-password=$PASSWORD \
	--template-file=$TEMPLATE_FILE \
	--run-list=$RUN_LIST
