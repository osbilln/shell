yum install -y http://rdo.fedorapeople.org/rdo-release.rpm
yum install -y openstack-packstack
packstack --gen-answer-file=packstack-install.txt
packstack --answer-file=packstack-install.txt
