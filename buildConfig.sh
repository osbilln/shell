#!/bin/bash
base="/etc/haproxy"
dest="$base/haproxy.cfg"

# Global section
cat "$base/global.cfg" > "$dest"

#find frontends
for frontend in `find $base -type d -name "*-*"`; do
  #copy frontend config to haproxy
  cat "$frontend/frontend.cfg" >> "$dest"
  # check default.cfg
  if [ -e "$frontend/default.cfg" ]; then
    cat "$frontend/default.cfg" >> "$dest"
    #find acl for backends
    for acl in `find $frontend/ -type f -name "acl.cfg"`; do
      cat "$acl" >> "$dest"
    done
  else 
  #find blocks
    for backend in `find $frontend -maxdepth 1 -type d | tail -n +2`; do
      cat "$backend/acl.cfg" >> "$dest" 
      cat "$backend/block.cfg" | awk 'BEGIN { printf "  block if " } { printf "!%s ", $0 }' >> "$dest"
      echo >> "$dest"
    done
  fi
  #find backends
  for backend in `find $frontend -maxdepth 1 -type d | tail -n +2`; do
    cat "$backend/backend.cfg" >> "$dest"
    #find servers
    for server in `find $backend -type f -name "server.*.cfg"`; do
      cat "$server" >> "$dest"
    done
  done
done
/etc/init.d/haproxy reload
