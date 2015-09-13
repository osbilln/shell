#!/bin/bash

DEST_HOST="" # IP or FQDN of the destination host
DEST_USER="" # Username of the user with permissons to write in the destination host
HDD_DEST_DIR="" # Directory where the VM's hdd storage dir in the destination host
HDD_ORIG_DIR="" # Directory where the VM's hdd storage dir in the current host
CONF_DEST_DIR="/tmp" # Directory where the temp files will be generated in the destination host. Default is fine.

VM=$1 # Grab the VM name from the command line arg list.

clear
cd /tmp



DISCO=$( virsh dumpxml $VM  | grep img | cut -d"'" -f2 | cut -d"/" -f4 )
virsh dumpxml $VM >> export.xml

echo "Exporting VM $VM..."

scp export.xml $DEST_USER@$DEST_HOST:/$CONF_DEST_DIR
scp $HDD_ORIG_DIR/$DISCO $DEST_USER@$DEST_HOST:/$HDD_DEST_DIR/$DISCO

ssh $DEST_USER@$DEST_HOST virsh create $CONF_DEST_DIR/export.xml
ssh $DEST_USER@$DEST_HOST rm -rf  $CONF_DEST_DIR/export.xml

echo "VM $VM successfully exported!!."
