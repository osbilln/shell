#!/bin/bash



for conf in krb5.conf realmd.conf resolv.conf sssd.conf 
  do
    if [ $conf == "sssd.conf" ];then 
    	cd /etc
    	if [ ! -d "sssd"]
        	mkdir /etc/sssd
    	fi
       wget -O /etc/sssd/$conf http://192.168.201.25:/nh_shares/common_packages/$conf
    fi
    wget -O /etc/$conf http://192.168.201.25:/nh_shares/common_packages/$conf
done
