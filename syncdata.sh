#!/bin/bash

rsync -azvt fi-prod-couchbase-1c:/tmp/couchbase.tar.gz .
rsync -azvt fi-prod-messaging-1b:/data/totvslabs .
tar zcvf totvslabs.tar.gz totvslabs/ 
rsync -azvt fi-prod-keystore-1b:/cloudpass/backend/build/bin/CloudpassKeystore .


echo "syncing to brazil nimbvs"
echo "syncing search data"
scp -rp totvslabs.tar.gz brmessaging01:/data/.
echo "syncing database data"
scp -rp couchbase.tar.gz brcouchbase02:/tmp/.
echo "syncing new keystore "
scp -rp  CloudpassKeystore brkeystore01:/cloudpass/backend/build/bin/CloudpassKeystore
