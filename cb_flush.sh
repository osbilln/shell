hostname="localhost"
if [ "$1" != "" ]; then 
   hostname=$1
fi

username="Administrator"
password="password"
mainBucketName="cloudpass"
sessionBucketName="SessionInfo"
activityBucketName="Activity"

echo "Flushing bucket"
echo "hostname: $hostname"
echo "Main bucket name: $mainBucketName"
echo "Session bucket name: $sessionBucketName"
echo "Activity bucket name: $activityBucketName"

couchbase-cli bucket-flush -c ${hostname}:8091 --user=${username} --password=${password} --bucket=${mainBucketName}
couchbase-cli bucket-flush -c ${hostname}:8091 --user=${username} --password=${password} --bucket=${sessionBucketName}
couchbase-cli bucket-flush -c ${hostname}:8091 --user=${username} --password=${password} --bucket=${activityBucketName}
