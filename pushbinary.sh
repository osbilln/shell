#!/bin/bash
set -x

ssh $1 -C 'cd /etc/yum.repos.d/ && /bin/rm -f Cen*'

cd /root/chef/network
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
scp -r idmapd.conf  $1:/etc
scp -r sudoers $1:/etc
scp -r sshd_config $1:/etc/ssh
scp -r network $1:/etc/sysconfig/

# WEB NODE 
scp -rp /usr/java/jre1.6.0_21 $1:/usr/java/
ssh $1 -C "mkdir -p /opt/report_core/bin"
ssh $1 -C "ln -s /usr/java/jre1.6.0_21 /usr/java/latest" 
ssh $1 -C "ln -s /usr/java/latest /usr/java/default" 
## Application Push
cd /root/chef/application
scp -rp /opt/apache-tomcat-6.0.26 $1:/opt/
ssh $1 -C "ln -s /opt/apache-tomcat-6.0.26 /opt/tomcat" 

# scp start_report.sh $1:/opt/report_core/bin
scp WebCoreTC $1:/etc/init.d/

# scp start_report.sh stg01soffice:
# scp stop_report.sh stg01soffice:
# scp -rp binary $1:/etc/init.d/
# scp -rp *binary* $1:/opt/binary/bin
# scp -rp start_binary.sh $1:/opt/binary/bin
# scp -rp start_binary.sh $1:/opt/binary_core/bin
# scp -rp *binary* $1:/opt/binary_core/bin
# scp -rp stop_binary.sh $1:/opt/binary_core/bin
# scp -rp stop_binary.sh $1:/opt/binary_core/bin
# scp -rp start_binary.sh $1:/opt/binary_core/bin
# scp -rp slc $1:/etc/init.d/slc
# scp -rp start_slc.sh $1:/opt/service_locator_core/bin/.
# scp -rp stop_slc.sh $1:/opt/service_locator_core/bin/.
# scp -rp stop_redirect.sh $1:/opt/redirect_core/bin/.
# scp -rp stop_Redirect.sh $1:/opt/redirect_core/bin/.
# scp -rp stop_redirect.sh $1:/opt/redirect_core/bin/.
# scp -rp start_redirect.sh $1:/opt/redirect_core/bin/.
# scp -rp redirect $1:/etc/init.d
# scp -rp stg01s:/shared_OLD/binary .
# scp -rp toolsoffice:/etc/profile .
# scp -rp jdk1.6.0_25/ $1:/usr
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
ssh $1 -C "chkconfig WebCoreTC on"
ssh $1 -C "chkconfig ypbind on"
