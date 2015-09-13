#!/bin/bash -x
server=$1
eval $(echo $2 | sed -e 's#^\(.*\)://\(.*\):\([0-9]*\)\(/.*\)$#proto="\1";balance_type="\2";fend_port="\3";url="\4"#')
cert=$3

base="/etc/haproxy"
backend_name=`md5sum <<< $proto$fend_port$url | cut -d " " -f1`
path="$fend_port/$proto-$fend_port"
server_name=`md5sum <<< $server | cut -d " " -f1`

###Check params###
if [ -z "$proto" -o -z "$fend_port" -o -z "$balance_type" -o -z "$server" ]; then
  echo "Not enought params to proceed"
  exit 1
fi

[ -z "$url" ] && url="/"

case $proto in
  http) mode="http" 
        proto="http";;
  https)
        stat_ssl=1
        mode="http" 
	proto="https";;
  tcp)  mode="tcp" 
        proto="tcp";;
  ssl) 
        stat_ssl="1"
        mode="tcp" 
        proto="ssl";;
  *) echo "Wrong proto" && exit 1 ;; 
esac

if [ "$mode" == tcp ] && [ "$url" != '/' ]; then
  echo "URL could be / only, when mode tcp or ssl"
  exit 1
fi

addFrontend(){
if [ ! -d "$base/$fend_port/" ]; then
    mkdir -p "$base/$path"
else
  echo "Frontend with $fend_port exists"
  exit 1;
fi
#with ssl
if [ "$stat_ssl" = 1 ]; then
  #check ssl cert 
  if [ ! -z $cert ]; then
    cp "$cert" "$base/$path/ssl.pem"
  else
    #generate cert
    openssl genrsa -out "$base/$path/ssl.key" 2048
    openssl req -new -x509 -extensions v3_ca -days 1100 -subj "/CN=*" -nodes -out "$base/$path/ssl.pem" -key "$base/$path/ssl.key"
    cat "$base/$path/ssl.key" >> "$base/$path/ssl.pem"
  fi
  cat << EOF > "$base/$path/frontend.cfg"

frontend $proto-$fend_port
  bind *:$fend_port ssl crt $base/$path/ssl.pem ciphers ALL:!ADH:!LOW:!SSLv2:!EXP:!RC4-SHA:!DES-CBC3-SHA:+HIGH:+MEDIUM
  mode $mode
EOF

  if [ "$mode" == tcp ]; then
    cat << EOF >> "$base/$path/frontend.cfg"
  option tcplog
EOF
  else
    cat << EOF >> "$base/$path/frontend.cfg"
  option httplog
EOF
  fi
##w/o ssl
else
  cat << EOF > "$base/$path/frontend.cfg"

frontend $proto-$fend_port
  bind *:$fend_port
  mode $mode
EOF
  if [ "$mode" == tcp ]; then
    cat << EOF >> "$base/$path/frontend.cfg"
  option tcplog
EOF
  else
    cat << EOF >> "$base/$path/frontend.cfg"
  option httplog
EOF
  fi
fi
}

addBackend(){
if  [ -d "$base/$path/$backend_name" ]; then
  echo "Backend with such params exist"
  exit 1
else
  mkdir $base/$path/$backend_name 
fi
#default backend acl
if [ "$url" = "/" ]; then
  cat << EOF > "$base/$path/default.cfg"
  default_backend $backend_name
EOF
else
  #make block directive
  echo "acl-$backend_name" > "$base/$path/$backend_name/block.cfg"
fi
  #make acl
  cat << EOF > "$base/$path/$backend_name/acl.cfg"
  acl acl-$backend_name path_beg $url
  use_backend $backend_name if acl-$backend_name 
EOF

###todo:
#balance types check 
#based on check add appropriate options
#when tcp option httplod should be switched to option tcplog
  if [ "$mode" = tcp ]; then
    cat << EOF > "$base/$path/$backend_name/backend.cfg"

backend $backend_name
  balance $balance_type
EOF
  else
    cat << EOF > "$base/$path/$backend_name/backend.cfg"

backend $backend_name
  option forwardfor
  cookie SERVERID insert nocache indirect
  balance $balance_type
EOF
  fi
}

###addServer###
[ ! -e "$base/$path/frontend.cfg" ] && addFrontend;
[ ! -d "$base/$path/$backend_name" ] && addBackend;
###todo
#balance types check
#based on check add appropriate options
if [ "$mode" == tcp ]; then
  cat << EOF > "$base/$path/$backend_name/server.$server.cfg"
  server $server_name $server check
EOF
else
  cat << EOF > "$base/$path/$backend_name/server.$server.cfg"
  server $server_name $server check cookie $server_name
EOF
fi
