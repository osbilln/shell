


for i in tomcat7 keystore search rmi adsync start-all stop-all 
  do
   scp -rp $i root@$1:/etc/init.d/.
done

for i in backup-all install-all
  do
   scp -rp $i root@$1:/usr/bin/
done
