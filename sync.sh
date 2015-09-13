

date > /root/sync.log
drdb1=172.16.125.9
rsync -azvv -e "ssh -i /root/.ssh/dr-db.pem" /data1/mysql-data-db7/usbankprod* ubuntu@172.16.125.9:/data/db7 >> sync.log

# rsync -rave "ssh -i ~/.ssh/dr-db.pem" /data1/mysql-data-db7/usbankprod ubuntu@172.16.125.9:/data/db7

echo ""
echo ""
echo ""
echo "END TIME"
data >> /root/sync.log
