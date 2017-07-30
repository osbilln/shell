#!/bin/bash
set -x
ssh $1 -C 'cp -rp /etc/yum.repos.d /etc/yum.repos.d_ORIG'
ssh $1 -C 'cd /etc/yum.repos.d/ && /bin/rm -f Cen*'

cd /root/chef/network
scp -r motd $1:/etc/motd
scp -r yum.conf $1:/etc/yum.conf
scp -r ifcfg-bond0 $1:/etc/sysconfig/network-scripts/ifcfg-bond0
scp -r ifcfg-eth0 $1:/etc/sysconfig/network-scripts/
scp -r ifcfg-eth1 $1:/etc/sysconfig/network-scripts/
scp -r modprobe.conf $1:/etc 
scp -r yp.conf $1:/etc
scp -r nsswitch.conf $1:/etc
scp -r resolv.conf $1:/etc
scp -r auto.master  $1:/etc
scp -r auto.home $1:/etc
scp -r auto.shared $1:/etc
scp -r idmapd.conf  $1:/etc
scp -r sudoers $1:/etc
scp -r sshd_config $1:/etc/ssh
scp -r network $1:/etc/sysconfig/
ssh $i -C "service ypbind start"
ssh $i -C "service autofs start"
#
ssh $1 -C "mkdir -p /var/log/zub"  
ssh $1 -C "chown -R eng:eng /var/log/zub"
# ssh $1 -C "mkdir -p /mnt/demo && chown -R eng:eng /mnt/demo"
# ssh $1 -C "cd / && ln -s /mnt/demo/binary ./shared"
# ssh $1 -C "ln -s /etc/localtime /etc/localtime_ORIG && ln -s /usr/share/zonetime/GMT ./localtime "
# WEB NODE 
scp -rp /usr/java/jre1.6.0_21 $1:/usr/java/
ssh $1 -C "ln -s /usr/java/jre1.6.0_21 /usr/java/latest" 
ssh $1 -C "ln -s /usr/java/latest /usr/java/default" 
ssh $1 -C "/bin/mv /usr/java/bin /usr/java/bin_ORIG" 
ssh $1 -C "cd /usr/java && ln -s default/bin bin" 
## Application Push
cd /root/chef/application
scp -rp /opt/apache-tomcat-6.0.26 $1:/opt/
ssh $1 -C "ln -s /opt/apache-tomcat-6.0.26 /opt/tomcat" 

# scp start_report.sh $1:/opt/report_core/bin
scp -rp ssapp01s.zubops.net:/opt/* /tmp/opt
scp -rp /tmp/opt/. $1:/opt

#
ssh $1 -C "chkconfig abrtd off"
ssh $1 -C "chkconfig acpid off"
ssh $1 -C "chkconfig atd off"
ssh $1 -C "chkconfig cpuspeed off"
ssh $1 -C "chkconfig haldaemon off"
ssh $1 -C "chkconfig irqbalance off"
ssh $1 -C "chkconfig kdump off"
ssh $1 -C "chkconfig lvm2-monitor off"
ssh $1 -C "chkconfig mdmonitor off"
ssh $1 -C "chkconfig messagebus off"
ssh $1 -C "chkconfig microcode_ctl off"
ssh $1 -C "chkconfig udev-post off"
ssh $1 -C "chkconfig postfix off"
ssh $1 -C "chkconfig WebCoreTC off"
ssh $1 -C "chkconfig ypbind on"

# Clean Up

ssh $1 -C "reboot"
