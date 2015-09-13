#!/bin/bash

ftp_server=10.55.95.226
ks_server=10.55.95.226
ftp_client=10.55.95.230
client_netmask=255.255.255.0

virt-install --hvm --debug --name=$1 --ram=4096 --accelerate --network bridge:br0 --network bridge:br1 --nographics --disk pool=vg_images,size=80 -l ftp://$ftp_server/pub/CentOS/6/os  --extra-args "console=ttyS0,115200 ks=ftp://$ks_server/pub/CentOS/6/os/ks.cfg ip=$ftp_client netmask=$client_netmask"

