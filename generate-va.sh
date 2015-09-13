#!/bin/bash


MASTER=10.165.4.60
ROOT=root@$MASTER


###
changehostname () {
ssh $ROOT -C "chef-hostname.sh $COMPANYNAME "
}

### 
dhcp () {
scp interfaces $ROOT:/etc/network/
}

###
exportva () {
export-to-va master $COMPANYNAME
}

###
importva () {
import-ovf $COMPANYNAME.ovf
}


if [ $# -eq 1 ]; then
   echo "change the host to new name"
   changehostname   
   echo " Change network to dhcp "   
   dhcp
   echo " export va to new company name"
   exportva
   echo " import va to vmware server for testing"
   importva

else

    echo -e "\n\nUsage: $0 {Company Name}"
    echo -e "ex: $0 stanford.fluigidentity.com\n\n"

fi
   

