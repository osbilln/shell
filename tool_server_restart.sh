# Restart postgreSql
sudo -u postgres pg_ctl restart -D /var/pgsql/data
# JIRA (as eng)
cd /opt/jira/bin 
sudo ./startup.sh
# Fisheye / Crucible (as eng)
cd /opt/fecru-2.2.0/bin
./start.sh
# Nexus as eng
cd /opt/nexus/nexus-webapp-1.4.0/bin/jsw/solaris-x86-32
./nexus start
