######################################################################
# Post processing:  KISS (Keep It Simple, Supid)
#
# This just marks the system as being under construction and copies
# a few files over for continuing the process.   To change the process
# you should change those files (which is easier to do anyway).  
# The files are: 
#   *  ks.sh    - shell script to configure system
#   *  kick-me-install.tar.gz - pre-packaged configuration
# In addition, a number of rpm packages are copied over.  They should
# be installed or updated automatically, but you may need to do this
# by hand.  Here's what you'll find and where
#   *  /tmp/updates - FC 3 *updates* to be applied after installation
#   *  /root/rpm    - local updates are *installed* on the system
#

cat /etc/motd >>/root/ks.log
cat /etc/motd
echo "search zubops.net" > /etc/resolv.conf
echo "nameserver 10.100.23.224" >> /etc/resolv.conf
echo "nameserver 4.2.2.4" >> /etc/resolv.conf
echo "10.100.23.210 repo" >> /etc/hosts

# cd /etc 
# mv yum.conf yum.conf_ORGI
# wget http://repo/centos/6/centosdeploy/yum.conf
# cp -rp /etc/yum.repos.d /etc/yum.repos.d_ORIG
# cd /etc/yum.repos.d
# /bin/rm -rf  Centos*
# cd 
yum clean all 
yum install yum-utils -y
yum  groupinstall "Administration Tools" "NFS file server" "Development Tools" "Server Configuration Tools" "PostgreSQL Database server" -y

yum -y install sgpio certmonger pam_krb5 krb5-workstation nscd
# RUBY GEM INSTALLED
cd /tmp
# This is OLD
# wget https://packages.endpoint.com/rhel/5/os/x86_64/ruby-enterprise-1.8.7-7.ep.x86_64.rpm
# wget https://packages.endpoint.com/rhel/5/ruby-enterprise-opt/x86_64/ruby-enterprise-1.8.7-7.ep.x86_64.rpm
# rpm -ivh ruby-enterprise-1.8.7-7.ep.x86_64.rpm 
yum install ruby ruby-devel ruby-libs ruby-irb ruby-rdoc make gcc -y
#
cd /tmp
# wget http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz
tar zxf rubygems-1.3.7.tgz
cd rubygems-1.3.7
ruby setup.rb 
/usr/bin/gem install chef --no-rdoc --no-ri
#
# wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
# rpm -ivh rpmforge-release-0.5.2-2.el5.rf.i386.rpm 
# yum install -y git-core git-svn 
# git clone git.idc1.zubops.net:/srv/chef-repo.git
#
#

mkdir /etc/chef && cd /etc/chef
wget http://repo/centos/6/centosdeploy/client.rb
wget http://repo/centos/6/centosdeploy/validation.pem
chmod 600 validation.pem
/etc/init.d/ntpd stop
rm -rf /etc/localtime
cd /etc
ln -s /usr/share/zoneinfo/GMT localtime
ntpdate pool.ntp.org
chkconfig ntpd on
# chef-client
# DONE

####################
# Get latest configuration files & RPM updates via ftp
# echo " * ftp connect to server... " >>/root/ks.log

# cd /root
# mkdir -p /root/rpm/updates/fedora/core/3
# mkdir -p /tmp/updates

# ftp -n 143.229.45.82  <<EOF     
# user anonymous  -ks@`hostname`
# binary
# lcd /root
# cd /pub/linux/local-updates/
# get ks.sh
# get kick-me-install.tar.gz
# lcd /root/rpm/
# prompt
# mget *.rpm
# cd /pub/linux/fedora/core/updates/3/i386/
# lcd /tmp/updates/
# mget *.rpm
# quit
# EOF

# ls ks.sh kick-me-install.tar.gz  >>/root/ks.log
# ls -R rpm                        >>/root/ks.log


####################
# If there is a config script ks.sh then run it!

#echo "  "                               >>/root/ks.log
#if [ -f /root/ks.sh ]; then
#   echo " * Execing /root/ks.sh..."     >>/root/ks.log
#   chmod +x /root/ks.sh
#   exec /root/ks.sh                     >>/root/ks.log
#else
#   echo " * No ks.sh found."            >>/root/ks.log
#fi
#
#exit 0
# EOF
