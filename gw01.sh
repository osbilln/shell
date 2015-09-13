#!/bin/bash
set -x
gw01=10.100.23.224
key="-i /root/.ssh/id_rsa_gw01"
cd /sdc/gw01
rsync -avzrt $gw01:/tftpboot /sdc/gw01/
rsync -avzrt $gw01:/data /sdc/gw01/
