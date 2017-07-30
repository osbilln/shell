for i in `cat sserver.text`
  do 
	echo "$i ==================================================="
	ssh $i -C cat /etc/motd
  done
