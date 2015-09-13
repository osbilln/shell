hostname="localhost"
if [ "$1" != "" ]; then
   hostname=$1
fi

username="Administrator"
password="password"

curl -d "updateInterval=20000&updateMinChanges=5&replicaUpdateMinChanges=60000" http://${username}:${password}@${hostname}:8091/settings/viewUpdateDaemon
