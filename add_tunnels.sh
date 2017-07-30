#!/bin/bash

tunnel_port=22000
ssh_port=22

for i in `cat ../naehas/servers/drlinux`
  do
   echo $i 
   echo "ssh -N -f billn@dev -L $tunnel_port:$i:$ssh_port -n /bin/bash" >> .sungard_tunnel
   echo "alias $i=ssh -i ~/.ssh/dev_id_rsa -p $tunnel_port billn@localhost" >> .sungard 
   tunnel_port=$((tunnel_port + 1))
done
