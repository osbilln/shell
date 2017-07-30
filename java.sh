#!/bin/bash
SERVER=$1
JRE=jre1.6.0_21
for i in `cat $SERVER`
  do
   echo $i
#    scp -rp /usr/java/$2 $i:/usr/java
    ssh $i -C "rm -rf /usr/bin/java"
    ssh $i -C "cd /usr/bin && ln -s /usr/java/default/bin/java ./"
    ssh $i -C "cd /usr/java && rm -rf latest && ln -s $JRE latest"
   ssh $i -C "/usr/bin/java -version"
   ssh $i -C "yum remove java-1.6.0-openjdk-1.6.0.0-1.36.b17.el6_0.x86_64 -y"
   ssh $i -C "rpm -qa |grep java"
  echo " ================================================= "
done
