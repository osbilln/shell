
FILE=fluigidentity_vm.zip
FROMDIR=virtualappliance
SERVER=brcdn02
REMOTEDIR=/var/www/cloudpass/data/virtualappliance

cd $FROMDIR
scp -r $FILE root@$SERVER:$REMOTEDIR
