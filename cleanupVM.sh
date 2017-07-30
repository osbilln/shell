rm ~root/.bash_history
rm ~ubuntu/.bash_history
unset HISTFILE
logrotate -f /etc/logrotate.conf
rm /var/log/*.gz /var/log/*.1
rm /var/log/boot.log /var/log/dmesg*
rm -rf /tmp/* /var/tmp/*
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/lastlog
rm -f /etc/udev/rules.d/70*
rm -rf /etc/ssh/*key*
