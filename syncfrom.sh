



for i in tomcat7 keystore search rmi adsync start-all stop-all 
  do
   scp -rp fluig@$1:/etc/init.d/$i .
done

for i in backup-all install-all
  do
   scp -rp fluig@$1:/usr/bin/$i .
done
