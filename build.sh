#!/bin/bash
set -x
NEWNODE=$1
scp -rp setupServer_basic.sh $NEWNODE:
scp -rp configuration.cfg $NEWNODE:
ssh $1 -C "chmod 700 setupServer.sh  && /bin/bash setupServer_basic.sh"
# ssh $1 -C "apt-get install --assume-yes --force-yes aptitude"
