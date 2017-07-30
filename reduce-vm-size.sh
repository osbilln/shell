#!/bin/sh
 
# Credits to:
#  - http://vstone.eu/reducing-vagrant-box-size/
#  - https://github.com/mitchellh/vagrant/issues/343
#  - https://gist.github.com/adrienbrault/3775253
 
# Unmount project
umount /vagrant
 
# Remove APT cache
apt-get clean -y
apt-get autoclean -y
 
# Zero free space to aid VM compression
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
 
# Remove tomcat log files
find /var/log/tomcat7/ -type f | xargs rm -f

# Remove log files
find /var/ -type f | xargs rm -f

# Remove tomcat log files
find /var/ -type f | xargs rm -f

# Remove chef files
find /var/chef/cache -type f | xargs rm -f

# Remove APT files
# find /var/lib/apt -type f | xargs rm -f
 
# Remove documentation files
find /var/lib/doc -type f | xargs rm -f
 
# Remove Virtualbox specific files
rm -rf /usr/src/vboxguest* /usr/src/virtualbox-ose-guest*
 
# Remove Linux headers
rm -rf /usr/src/linux-headers*
 
# Remove Unused locales (edit for your needs, this keeps only en* and pt_BR)
find /usr/share/locale/{af,am,ar,as,ast,az,bal,be,bg,bn,bn_IN,br,bs,byn,ca,cr,cs,csb,cy,da,de,de_AT,dz,el,en_AU,en_CA,eo,es,et,et_EE,eu,fa,fi,fo,fr,fur,ga,gez,gl,gu,haw,he,hi,hr,hu,hy,id,is,it,ja,ka,kk,km,kn,ko,kok,ku,ky,lg,lt,lv,mg,mi,mk,ml,mn,mr,ms,mt,nb,ne,nl,nn,no,nso,oc,or,pa,pl,ps,qu,ro,ru,rw,si,sk,sl,so,sq,sr,sr*latin,sv,sw,ta,te,th,ti,tig,tk,tl,tr,tt,ur,urd,ve,vi,wa,wal,wo,xh,zh,zh_HK,zh_CN,zh_TW,zu} -type d -delete
 
# Remove bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history
 
# Cleanup log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;
 
# Whiteout root
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
count=$((count -= 1))
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;
 
# Whiteout /boot
count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
count=$((count -= 1))
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;
 
# Whiteout swap 
swappart=`cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}'`
swapoff $swappart;
dd if=/dev/zero of=$swappart;
mkswap $swappart;
swapon $swappart;
