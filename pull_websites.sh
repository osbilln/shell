* * * * * /root/pull_websites.sh >> /root/pull_websites.log 2>&1 &


cd /cloudpass/websites
/usr/bin/git reset --hard
/usr/bin/git pull
cp -R * /var/www/
cd /var/www
/bin/rm -rf inc

