cat > ~/keystore <<-EOF
#!/bin/bash -e
### BEGIN INIT INFO
# Provides: keystore
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description:
# Description: script to start/stop Keystore Server
### END INIT INFO

export BACKEND_HOME=\${BACKEND_HOME:-/cloudpass/backend/build}
export JAVA_HOME=\${JAVA_HOME:-/usr/lib/jvm/default-java}

case "\$1" in
    start)
        cd \${BACKEND_HOME}/bin >&2
        nohup \${BACKEND_HOME}/bin/keystore_server_start.sh > /root/keystore.log 2>&1 &
        ;;
    stop)
        ps ax | grep -i keystore 2>/dev/null | grep -v grep | awk '{print \$1}' | xargs kill -15
        sleep 5
        ;;
    *)
        echo "Usage: \$0 {start|stop}" >&2
        exit 1
        ;;
esac
EOF

sudo mv ~/keystore /etc/init.d/keystore
sudo chmod +x /etc/init.d/keystore
sudo chown root:root /etc/init.d/keystore

sudo update-rc.d keystore defaults
sudo service keystore stop 2>/dev/null
