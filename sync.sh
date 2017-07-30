<<<<<<< HEAD
<<<<<<< HEAD
#!/bin/bash

cd 
src_dir_dropbox="Dropbox"
src_dir_googledrive="Google\ Drive"
dst_dir_icloud="iCloud"
dst_dir_local="/Volumes/backup/tools"
sync="rsync -azvt"
cd $iCloud
	eval $sync $src_dir_dropbox/ .
	eval $sync $src_dir_googledrive/ .
cd $dst_dir_local
	eval $sync "~/iCloud/*" .
=======
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3


date > /root/sync.log
drdb1=172.16.125.9
rsync -azvv -e "ssh -i /root/.ssh/dr-db.pem" /data1/mysql-data-db7/usbankprod* ubuntu@172.16.125.9:/data/db7 >> sync.log

# rsync -rave "ssh -i ~/.ssh/dr-db.pem" /data1/mysql-data-db7/usbankprod ubuntu@172.16.125.9:/data/db7

echo ""
echo ""
echo ""
echo "END TIME"
data >> /root/sync.log
<<<<<<< HEAD
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
=======
>>>>>>> 4a4eaaa47f616fdfc5699327b8fd1f321bdb02b3
