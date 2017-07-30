!/bin/bash

SERVER=$1
for i in `cat $SERVER`
  do
    echo " ================================= "
    nmap -F $i
#    nmap -sS -O -T $i
    echo "$i"
  done
