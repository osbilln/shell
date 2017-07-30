#!/bin/bash -x
base="/etc/haproxy"
backend_name=`md5sum <<< $proto$fend_port$url | cut -d " " -f1`
server_name=`md5sum <<< $server | cut -d " " -f1`

server=$1
[ -z "$server" ] && exit 1;
eval $(echo $2 | sed -e 's#^\(.*\)://\(.*\):\([0-9]*\)\(/.*\)$#proto="\1";balance_type="\2";fend_port="\3";url="\4"#')

if [  -n "$proto" -a -n "$fend_port" -a -n "$balance_type" -a -n "$url" ]; then

path="$fend_port/$proto-$fend_port"
 serv_num=`find $base/$fend_port -type f -name "server.*.cfg" | wc -l`
 if [ "$serv_num" -eq 1 ]; then
   rm -rf "$base/$fend_port"
 else
   #find backends
   bend_path=`find $base/$path -type d | tail -n +2`
   #count servers in backend path
   for i in $bend_path; do
      bend_serv_num=`find $bend_path -type f -name "server.*cfg" | wc -l`
      if [ "$bend_serv_num" -gt 1 ]; then
        rm -rf "$bend_path/$server"
      else
        rm -rf "$bend_path"
      fi
   done
 fi
 bend_num=`find "$fend_port/$proto-$fend_port" -maxdepth 1 -type d | tail -n +2 | wc -l`
 if [ $bend_num -eq 0 ]; then
   rm -rf "$fend_port"
 fi
else
#find all servers in base
  for serv_path in `find $base -type f -name server.$server.cfg`; do
    rm -rf "$serv_path"
    bend_path=`dirname "$serv_path"`
    serv_num=`find "$bend_path" -type f -name "server.*"| wc -l`
    if [ "$serv_num" -eq 0 ]; then
      rm -rf "$bend_path"
    fi
    fend_dir=`dirname "$bend_path"`
    fend_path=`dirname "$fend_dir"`
    bend_num=`find $fend_dir -maxdepth 1 -type d | tail -n +2 | wc -l`
    if [ $bend_num -eq 0 ]; then
      rm -rf "$fend_path"
    fi
  done
fi
