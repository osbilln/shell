wget "http://packages.couchbase.com/releases/2.0.1/couchbase-server-enterprise_x86_64_2.0.1.deb"
sudo apt-get -y install libssl0.9.8 
sudo dpkg -i couchbase-server-enterprise_x86_64_2.0.1.deb

export PATH=/opt/couchbase/bin:$PATH

#Cluster initialization
couchbase-cli cluster-init \
  -c localhost:8091 \
  --cluster-init-username=Administrator \
  --cluster-init-password=password \
  --cluster-init-port=8091 \
  --cluster-init-ramsize=1024

#Create buckets
couchbase-cli bucket-create \
  -c localhost:8091 \
  -u Administrator -p password \
  --bucket=cloudpass \
  --bucket-type=couchbase \
  --bucket-ramsize=500

#cbepctl localhost:11210 -b cloudpass set flush_param flushall_enabled true
couchbase-cli bucket-create \
  -c localhost:8091 \
  -u Administrator \
  -p password \
  --bucket=Activity \
  --bucket-type=couchbase \
  --bucket-ramsize=300

#cbepctl localhost:11210 -b Activity set flush_param flushall_enabled true
couchbase-cli bucket-create \
  -c localhost:8091 \
  -u Administrator \
  -p password \
  --bucket=SessionInfo \
  --bucket-type=memcached \
  --bucket-ramsize=200

