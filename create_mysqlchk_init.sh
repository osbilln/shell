cat > ~/mysqlchk <<-EOF
#!/bin/bash -e
### BEGIN INIT INFO
# Provides: mysqlchk
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description:
# Description: script to start/stop mysql cluster status check server
### END INIT INFO

case "\$1" in
    start)
        nohup python /etc/mysql/clustercheck.py > /dev/null 2>&1 &
        ;;
    stop)
        ps ax | grep -i "clustercheck.py" 2>/dev/null | grep -v grep | awk '{print \$1}' | xargs kill -15 2>/dev/null
        sleep 5
        ;;
    *)
        echo "Usage: \$0 {start|stop}" >&2
        exit 1
        ;;
esac
EOF

sudo mv ~/mysqlchk /etc/init.d/mysqlchk
sudo chmod +x /etc/init.d/mysqlchk
sudo chown root:root /etc/init.d/mysqlchk

sudo update-rc.d mysqlchk defaults
sudo service mysqlchk stop 2>/dev/null
