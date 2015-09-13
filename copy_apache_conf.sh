#!/bin/bash

set -x

declare -A SERVER_MAP

SERVER_MAP[172.20.16.23]="qa"
SERVER_MAP[172.20.18.13]="qa1b"
SERVER_MAP[172.20.16.11]="brapp01"
SERVER_MAP[172.20.16.12]="brapp02"
SERVER_MAP[10.80.128.4]="jvdev01"
SERVER_MAP[10.165.4.191]="mvdev01"
# for server in "${!SERVER_MAP[@]}"

for server in brqa01 brqa02 brapp01 brapp02 mvdev01 jvdev01
  do
    scp -rp root@$server:/etc/apache2/apache2.conf $server.apache2.conf
    scp -rp root@$server:/etc/apache2/sites-available/default $server.default
    scp -rp root@$server:/etc/apache2/sites-available/default-ssl $server.default-ssl

done





