h
rt ARCHIVA_RELEASE="1.4-M3"

# shutdown existing instance
ppid=$(ps ax | grep -i apache-archiva | grep -v grep | awk '{print $1}')
if [ "$ppid" != "" ]; then
    ps --ppid $ppid | awk '{print $1}' | grep -v PID | sudo xargs kill -9 2>/dev/null
    sudo kill -9 $ppid 2>/dev/null
fi

# set enviornment variable
if [ $(grep -c ARCHIVA_BASE /etc/environment) -eq 0 ]; then
	cp /etc/environment ~/environment
	echo "ARCHIVA_BASE=/opt/archiva" >> ~/environment
	sudo mv ~/environment /etc/environment
	export ARCHIVA_BASE=/opt/archiva
fi

# download project binary
cd ~
[ ! -e "apache-archiva-${ARCHIVA_RELEASE}-js-bin.tar.gz" ] && wget "http://apache.osuosl.org/archiva/${ARCHIVA_RELEASE}/binaries/apache-archiva-${ARCHIVA_RELEASE}-js-bin.tar.gz"
[ ! -e "apache-archiva-js-${ARCHIVA_RELEASE}" ] && tar -zxf apache-archiva-${ARCHIVA_RELEASE}-js-bin.tar.gz

export ARCHIVA="apache-archiva-js-${ARCHIVA_RELEASE}"

# create needed folders
mkdir -p $ARCHIVA/logs 2>/dev/null
mkdir -p $ARCHIVA/data 2>/dev/null
mkdir -p $ARCHIVA/temp 2>/dev/null
mkdir -p $ARCHIVA/conf 2>/dev/null

# configuration
sed 's/8080/8580/g' $ARCHIVA/conf/jetty.xml > $ARCHIVA/conf/jetty.xml.1
mv $ARCHIVA/conf/jetty.xml.1 $ARCHIVA/conf/jetty.xml

# turn off password expiration
echo "security.policy.password.expiration.days=999999" > $ARCHIVA/conf/security.properties
echo "security.policy.password.expiration.enabled=false" >> $ARCHIVA/conf/security.properties

# move to target location
[ -e "$ARCHIVA_BASE" ] && sudo rm -Rf $ARCHIVA_BASE
[ -e "/opt/$ARCHIVA" ] && sudo rm -Rf /opt/$ARCHIVA
sudo mv $ARCHIVA /opt/
cd /opt/
sudo ln -s $ARCHIVA archiva
sudo chown -R root:root /opt/$ARCHIVA

# turn off password expiration
echo "security.policy.password.expiration.days=999999" > ~/security.properties
echo "security.policy.password.expiration.enabled=false" >> ~/security.properties
sudo mv ~/security.properties /opt/$ARCHIVA


cat > ~/archiva <<-EOF
#!/bin/bash -e
#
# script for starting/stopping the Archiva standalone server
#

export ARCHIVA_BASE=\${ARCHIVA_BASE:-/opt/archiva}
export JAVA_HOME=\${ARCHIVA_BASE:-/opt/jdk}
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jdk/bin:/opt/maven/bin"

case "\$1" in
    start)
        cd \${ARCHIVA_BASE}/bin  >&2
        ./archiva start >&2 &
        ;;
    stop)
        cd \${ARCHIVA_BASE}/bin  >&2
        ./archiva stop >&2 &
        ;;
    *)
        echo "Usage: \$0 {start|stop}" >&2
        exit 1
        ;;
esac
EOF

sudo mv ~/archiva /etc/init.d/archiva
sudo chmod +x /etc/init.d/archiva
sudo chown root:root /etc/init.d/archiva

sudo update-rc.d archiva defaults 2>/dev/null
sudo /etc/init.d/archiva stop 2>/dev/null

sudo /etc/init.d/archiva start &

# http://10.165.4.66:8580
# administrator: admin
# administrator password: 7(5YO$<y]?&.*6
