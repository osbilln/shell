scp -rp /var/www/html/centos/5.7/os/x86_64/CentOS/centos-release-5-7.el5.centos.x86_64.rpm $1:
scp -rp /var/www/html/centos/5.7/os/x86_64/CentOS/centos-release-notes-5.7-0.x86_64.rpm $1:
ssh $1 -C "rpm -Uvh centos-release*"
ssh $1 -C "yum update"
ssh $1 -C "reboot"
