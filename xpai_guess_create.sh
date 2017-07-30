knife xapi guest create "MySpiffyBox" "pub_network" --host http://sandbox/ \
  -B "dns=8.8.8.8 ks=http://192.168.6.4/repo/ks/default.ks ip=192.168.6.7 netmask=255.255.255.0 gateway=192.168.6.1" \
  -R http://192.168.6.5/repo/centos/5/os/x86_64 -C 4 -M 4g -D 5g 
