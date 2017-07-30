#bin/bash

pushd .
#issue sudo command before copying the file also verify write permission
sudo mkdir something
sudo rm -rvf something

mkdir  /tmp/mongoInstall
cd /tmp/mongoInstall
curl http://downloads.mongodb.org/osx/mongodb-osx-x86_64-2.0.0.tgz > mongo.tgz
tar xzf mongo.tgz
sudo cp -rvf mongodb-osx-x86_64-2.0.0/bin/* /opt/local/bin/

sudo mkdir /usr/local/mongodb_data;

sudo mkdir /var/log/mongodb;
sudo touch /var/log/mongodb/output.log
sudo chmod 777 /var/log/mongodb/output.log

sudo mkdir /usr/local/mongodb/
sudo cp mongod.conf /usr/local/mongodb/

sudo cp org.mongo.mongod.plist /System/Library/LaunchDaemons/
sudo chown root:wheel /System/Library/LaunchDaemons/org.mongo.mongod.plist

sudo launchctl stop org.mongo.mongod
sudo launchctl unload /System/Library/LaunchDaemons/org.mongo.mongod.plist
sudo launchctl load /System/Library/LaunchDaemons/org.mongo.mongod.plist

echo "install mongo standalone complete"
rm -rvf mongodb-osx-x86_64-2.0.0

echo "installing mongo php stuff"
sudo pecl install mongo
echo "sudo su -"
echo  "echo \"extension=mongo.so\" >> /opt/local/etc/php5/php.ini"
echo "stop mongo: sudo launchctl stop org.mongo.mongod"
echo "unload mongo: sudo launchctl unload /System/Library/LaunchDaemons/org.mongo.mongod.plist"
echo "start mongo: sudo launchctl load /System/Library/LaunchDaemons/org.mongo.mongod.plist"
echo "restart apache: sudo /opt/local/apache2/bin/apachectl restart"
echo "count to 5 and then restart apache"
echo "verify it worked with: php --re mongo"
echo "should output a bunch of stuff"
echo "add athentication: from web page as this part is not scripted yet, http://cleanpowerfinance.onconfluence.com/display/CleanPowerFinance/Installing+Mongo" 
popd .

