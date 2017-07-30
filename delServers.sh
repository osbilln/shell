#!/bin/bash - 
base="/etc/haproxy"
backend_name=$1
[ -z "$backend_name" ] && exit 1;
eval $(echo $1 | sed -e 's#^\(.*\)://\(.*\):\([0-9]*\)\(/.*\)$#proto="\1";balance_type="\2";fend_port="\3";url="\4"#')

if [  -n "$proto" -a -n "$fend_port" -a -n "$balance_type" -a -n "$url" ]; then
  path="$fend_port/$proto-$fend_port"
  backend_path=`md5sum <<< $proto$fend_port$url | cut -d " " -f1`
  find $base/$path/$backend_path -type f -name "server.*" -exec rm -rf {} \;
fi 
