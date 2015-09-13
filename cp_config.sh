for i in yp.conf idmapd.conf sendmail.cf auto.home auto.master auto.home auto.master \
	idmapd.conf nsswitch.conf profile resolv.conf sudoers upgrade.sh \
	yp.conf yum.conf
do
  echo $i
  scp -rp $i $1:/etc
done
