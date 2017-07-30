cat > ~/search <<-EOF
#!/bin/bash -e
### BEGIN INIT INFO
# Provides: search
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description:
# Description: script to start/stop Search/NLS Server
### END INIT INFO

export BACKEND_HOME=\${BACKEND_HOME:-/cloudpass/backend/build}
export JAVA_HOME=\${JAVA_HOME:-/usr/lib/jvm/default-java}

case "\$1" in
    start)
        cd \${BACKEND_HOME}/bin >&2
        nohup \${BACKEND_HOME}/bin/search_service_start.sh > /data/logs/search.log 2>&1 &
        ;;
    stop)
        cd \${BACKEND_HOME}/bin >&2
        ps ax | grep -i search 2>/dev/null | grep -v grep | awk '{print \$1}' | xargs kill -15
        sleep 5
        ;;
    *)
        echo "Usage: \$0 {start|stop}" >&2
        exit 1
        ;;
esac
EOF

sudo mv ~/search /etc/init.d/search
sudo chmod +x /etc/init.d/search
sudo chown root:root /etc/init.d/search

sudo update-rc.d search defaults
sudo service search stop 2>/dev/null
