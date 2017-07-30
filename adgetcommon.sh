#!/bin/bash


for common in common-session
  do
    wget -O /etc/pam.d/$common http://192.168.201.25:/nh_shares/common_packages/$common
done
