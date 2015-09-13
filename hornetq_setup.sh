#!/bin/bash

# kill all existing processes
ps ax | grep hornetq | grep -v setup | grep -v grep | awk '{print $1}' | xargs sudo kill -9 2>/dev/null

# ===========================================================
#
# HornetQ Installation
#
# ===========================================================

cd ~
if [ ! -e hornetq-2.2.14.Final.tar.gz ]; then
  wget "http://downloads.jboss.org/hornetq/hornetq-2.2.14.Final.tar.gz"
fi
tar zxf hornetq-2.2.14.Final.tar.gz
sudo rm -Rf /opt/hornetq-2.2.14.Final
sudo mv hornetq-2.2.14.Final /opt/
cd /opt/
sudo rm -Rf hornetq
sudo ln -s hornetq-2.2.14.Final hornetq
sudo chown -R root:root /opt/hornetq-2.2.14.Final


# install asynchronize IO library
sudo apt-get -y install libaio1 libaio-dev


# ===========================================================
#
# HornetQ Configuration
# 
# ===========================================================


# ---
# 1. setup HornetQ environment variable
#

# a. add environment variable
sed '/HORNETQ_HOME/d' /etc/environment > ~/environment
echo "export HORNETQ_HOME=\"/opt/hornetq\"" >> ~/environment
sudo mv ~/environment /etc/environment
sudo chown root:root /etc/environment

# b. set MYIP variable
sed '/MYIP/d' ~/.bash_profile > ~/.bash_profile.1
rm ~/active_inet.txt 2>/dev/null
for iface in  `ifconfig -s | sed '1d' | cut -d" " -f1` ; do
    case $iface in
    lo*)     continue ;;
    esac
    ifconfig $iface | grep -q 'inet ' && echo $iface >> ~/active_inet.txt
done
iface=$(cat ~/active_inet.txt)
rm ~/active_inet.txt 2>/dev/null
myip=$(ifconfig $iface | grep 'inet ' | cut -d":" -f2 | awk '{ print $1}')

cat >> ~/.bash_profile.1 <<-EOF
export MYIP="$myip"
EOF
mv ~/.bash_profile.1 ~/.bash_profile
. ~/.bash_profile

export MYIP="0.0.0.0"
export HORNETQ_HOME="/opt/hornetq"

echo "MY_IP = $MYIP"

# ---
# 2. Create auto start script for HornetQ
#

cat > ~/hornetq <<-EOF

#!/bin/bash -e
#
# script for starting/stopping the HornetQ standalone server
#

export HORNETQ_HOME=\${HORNETQ_HOME:-/opt/hornetq}
export JAVA_HOME=\${HORNETQ_HOME:-/opt/jdk}
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin:/opt/maven/bin"

case "\$1" in
    start)
        cd \${HORNETQ_HOME}/bin >&2
        ./run.sh >&2 &
        ;;
    stop)
        cd \${HORNETQ_HOME}/bin >&2
        ./stop.sh >&2 &
        ;;
    *)
        echo "Usage: \$0 {start|stop}" >&2
        exit 1
        ;;
esac
EOF

sudo mv ~/hornetq /etc/init.d/hornetq
sudo chmod +x /etc/init.d/hornetq
sudo chown root:root /etc/init.d/hornetq

sudo update-rc.d hornetq defaults
sudo /etc/init.d/hornetq stop 2>/dev/null


# ---
# 3. backup properties
#

cd ${HORNETQ_HOME}/config/stand-alone/non-clustered/
sudo cp hornetq-beans.xml hornetq-beans.xml.original
sudo cp hornetq-configuration.xml hornetq-configuration.xml.original
sudo cp hornetq-jms.xml hornetq-jms.xml.original
sudo cp hornetq-users.xml hornetq-users.xml.original
sudo cp jndi.properties jndi.properties.original
sudo cp logging.properties logging.properties.original
cd ${HORNETQ_HOME}/bin
sudo cp run.sh run.sh.original
cd ~

# ---
# 4. change JNDI ports from 1099 to 2099, 1098 to 2098, and change localhost to external IP
#

sudo sed "s/109/209/g" ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-beans.xml.original > ~/hornetq-beans.xml
sudo sed "s/localhost/$MYIP/g" ~/hornetq-beans.xml > ~/hornetq-beans.xml.1
sudo mv ~/hornetq-beans.xml.1 ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-beans.xml
rm ~/hornetq-beans.xml

# verify
# sudo more ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-beans.xml



# ---
# 5. create lucene Application/Company/User queues
#

head -n -1 ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-jms.xml.original > ~/hornetq-jms.xml

cat >> ~/hornetq-jms.xml <<-EOF

   <queue name="lucene.LuceneQueue">
      <entry name="/queue/lucene/LuceneQueue"/>
      <durable>true</durable>
   </queue>

   <queue name="lucene.LuceneExpiryQueue">
      <entry name="/queue/lucene/LuceneExpiryQueue"/>
      <durable>true</durable>
   </queue>

   <queue name="neo4j.GraphicalDataQueue">
      <entry name="/queue/neo4j/GraphicalDataQueue"/>
      <durable>true</durable>
   </queue>

   <queue name="neo4j.GraphicalDataExpiryQueue">
      <entry name="/queue/neo4j/GraphicalDataExpiryQueue"/>
      <durable>true</durable>
   </queue>

   <topic name="AD.LoginRequestTopic">
      <entry name="/topic/AD/LoginRequestTopic"/>
   </topic>

   <topic name="AD.VerifiedTopic">
      <entry name="/topic/AD/VerifiedTopic"/>
   </topic>

   <topic name="AD.ImportUserTopic">
      <entry name="/topic/AD/ImportUserTopic"/>
   </topic>
   
   <topic name="AD.ChangePasswordTopic">
      <entry name="/topic/AD/ChangePasswordTopic"/>
   </topic>
   <topic name="AD.ChangePasswordResultTopic">
      <entry name="/topic/AD/ChangePasswordResultTopic"/>
   </topic>   
   
   <topic name="AD.CreateUserTopic">
      <entry name="/topic/AD/CreateUserTopic"/>
   </topic>
   <topic name="AD.CreateUserResultTopic">
      <entry name="/topic/AD/CreateUserResultTopic"/>
   </topic>

</configuration>
EOF

#sed "s/<\/entries>/<\/entries>|      <consumer-window-size>0<\/consumer-window-size>/g" ~/hornetq-jms.xml | tr '|' '\n' > ~/hornetq-jms.xml.1
sed "s/<\/entries>/<\/entries>|      <consumer-window-size>0<\/consumer-window-size>|      <client-failure-check-period>2147483646<\/client-failure-check-period>|      <connection-ttl>-1<\/connection-ttl>|      <reconnect-attempts>-1<\/reconnect-attempts>/g" ~/hornetq-jms.xml | tr '|' '\n' > ~/hornetq-jms.xml.1

# verify the file
#more ~/hornetq-jms.xml.1

# move back
sudo mv ~/hornetq-jms.xml.1 ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-jms.xml
rm -Rf ~/hornetq-jms.xml


# ---
# 6. setup lucene user
#

# get password MD5 hash

echo "(S'LxKdIf(6xdwH" | md5sum
echo "h+19W}O+*%$.8}b" | md5sum
echo "2P-Y3MG3bciFi5_" | md5sum
echo "31{yg-!5F|7f3]7" | md5sum
echo "U5J,3}ehPXfM)6n" | md5sum
echo "q7E76/#4_8{+.Bp" | md5sum
echo "K~sh&G1-M76%84x" | md5sum
echo "Q|yBgRX2]iY6=~c" | md5sum

# add lucene user

head -n -1 ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-users.xml.original > ~/hornetq-users.xml
sed "/<defaultuser/,/<\/defaultuser>/d" ~/hornetq-users.xml > ~/hornetq-users.xml.1

cat >> ~/hornetq-users.xml.1 <<-EOF

  <defaultuser name="admin" password="afefb285cd5c7e8cd93b13b2604ed177">
    <role name="administrator"/>
  </defaultuser>

  <user name="luceneManager" password="10adff7b10eb9aaf0ed9b4a116ab5e41">
    <role name="luceneManager"/>
  </user>

  <user name="luceneProducer" password="eeb8ed56f0bbb5ed8da68fda6a2605d6">
    <role name="luceneProducer"/>
  </user>

  <user name="luceneConsumer" password="d6056771391ac3894394b4f301c19150">
    <role name="luceneConsumer"/>
  </user>

  <user name="graphicalDataConsumer" password="04b8abbce5b94f3472ac1c20a76a014a">
    <role name="graphicalDataConsumer"/>
  </user>

  <user name="graphicalDataProducer" password="d6a6d0639afe16cf449fc6bb4ac66663">
    <role name="graphicalDataProducer"/>
  </user>

  <user name="adSyncServer" password="529b9cbefa343b41727046ca06655a1e">
    <role name="adSyncServer"/>
  </user>

</configuration>
EOF

# verify
# more ~/hornetq-users.xml.1
rm ~/hornetq-users.xml

# move back
sudo mv ~/hornetq-users.xml.1 ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-users.xml



# ---
# 7. setup Natty connector and ports
#
# a. change localhost to MYIP
# b. delete guest security settings and add lucene security settings

sed "s/localhost/$MYIP/g" ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-configuration.xml.original | head -n -1 > ~/hornetq-configuration.xml
sed "/<security-settings>/,/<\/address-settings>/d" ~/hornetq-configuration.xml > ~/hornetq-configuration.xml.1

cat >> ~/hornetq-configuration.xml.1 <<-EOF

   <!-- remove all guest security settings and add these settings below -->

   <security-settings>
      <security-setting match="#">
         <permission type="createNonDurableQueue" roles="administrator"/>
         <permission type="deleteNonDurableQueue" roles="administrator"/>
         <permission type="consume" roles="administrator"/>
         <permission type="send" roles="administrator"/>
      </security-setting>
      <security-setting match="jms.queue.lucene.#">
         <permission type="createNonDurableQueue" roles="luceneManager"/>
         <permission type="deleteNonDurableQueue" roles="luceneManager"/>
         <permission type="createNonDurableQueue" roles="luceneManager"/>
         <permission type="deleteNonDurableQueue" roles="luceneManager"/>
         <permission type="consume" roles="luceneConsumer"/>
         <permission type="send" roles="luceneProducer"/>
      </security-setting>
      <security-setting match="jms.queue.neo4j.#">
         <permission type="createNonDurableQueue" roles="neo4jManager"/>
         <permission type="deleteNonDurableQueue" roles="neo4jManager"/>
         <permission type="createNonDurableQueue" roles="neo4jManager"/>
         <permission type="deleteNonDurableQueue" roles="neo4jManager"/>
         <permission type="consume" roles="graphicalDataConsumer"/>
         <permission type="send" roles="graphicalDataProducer"/>
      </security-setting>
      <security-setting match="jms.topic.AD.#">
         <permission type="createNonDurableQueue" roles="adSyncServer"/>
         <permission type="deleteNonDurableQueue" roles="adSyncServer"/>
         <permission type="createNonDurableQueue" roles="adSyncServer"/>
         <permission type="deleteNonDurableQueue" roles="adSyncServer"/>
         <permission type="consume" roles="adSyncServer"/>
         <permission type="send" roles="adSyncServer"/>
      </security-setting>
   </security-settings>

   <address-settings>
      <!--default for catch all-->
      <address-setting match="#">
         <dead-letter-address>jms.queue.DLQ</dead-letter-address>
         <expiry-address>jms.queue.ExpiryQueue</expiry-address>
         <redelivery-delay>0</redelivery-delay>
         <max-size-bytes>10485760</max-size-bytes>       
	 <page-size-bytes>1048576</page-size-bytes>
         <message-counter-history-day-limit>10</message-counter-history-day-limit>
         <address-full-policy>PAGE</address-full-policy>
      </address-setting>
      <address-setting match="jms.queue.lucene.LuceneQueue">
         <expiry-address>jms.queue.lucene.LuceneExpiryQueue</expiry-address>
         <redelivery-delay>0</redelivery-delay>
         <max-size-bytes>10485760</max-size-bytes>
	 <page-size-bytes>1048576</page-size-bytes>
         <message-counter-history-day-limit>10</message-counter-history-day-limit>
         <address-full-policy>PAGE</address-full-policy>
      </address-setting>
      <address-setting match="jms.queue.neo4j.GraphicalDataQueue">
         <expiry-address>jms.queue.neo4j.GraphicalDataExpiryQueue</expiry-address>
         <redelivery-delay>0</redelivery-delay>
         <max-size-bytes>10485760</max-size-bytes>
	 <page-size-bytes>1048576</page-size-bytes>
         <message-counter-history-day-limit>10</message-counter-history-day-limit>
         <address-full-policy>PAGE</address-full-policy>
      </address-setting>
   </address-settings>

   <cluster-user>admin</cluster-user>
   <cluster-password>afefb285cd5c7e8cd93b13b2604ed177</cluster-password>

</configuration>
EOF

# verify
# more ~/hornetq-configuration.xml.1
rm ~/hornetq-configuration.xml

# move back
sudo mv ~/hornetq-configuration.xml.1 ${HORNETQ_HOME}/config/stand-alone/non-clustered/hornetq-configuration.xml


# ---
# 8. modify run.sh
#
# a. change localhost to MYIP
# b. change 1099 to 2099, 1098 to 2098

sed "s/109/209/g" ${HORNETQ_HOME}/bin/run.sh.original > ~/run.sh
sed "s/localhost/$MYIP/g" ~/run.sh > ~/run.sh.1
sed "s/\#export CLUSTER_PROPS/export CLUSTER_PROPS/" ~/run.sh.1 > ~/run.sh
rm ~/run.sh.1

# verify
# more ~/run.sh

# move back
sudo mv ~/run.sh ${HORNETQ_HOME}/bin/run.sh
sudo chmod +x ${HORNETQ_HOME}/bin/run.sh
sudo chown root:root ${HORNETQ_HOME}/bin/run.sh



# ===========================================================
#
# HornetQ Configuration
#
# 
# 
# ===========================================================

cd $HORNETQ_HOME/config/stand-alone/non-clustered/
sudo chown root:root *

# more hornetq-beans.xml
# more hornetq-jms.xml
# more hornetq-users.xml
# more jndi.properties
# more hornetq-configuration.xml

sudo service hornetq start &
