#!/bin/sh

port2=`expr 1 + $2`

echo "ssh i0$1.zubops.com -L $2:10.100.23.$1:$2 -L $port2:10.100.23.$1:$port2 -N"
echo launching jconsole with - service:jmx:rmi://localhost:$2/jndi/rmi://localhost:$port2/connector
jconsole service:jmx:rmi://localhost:$2/jndi/rmi://localhost:$port2/connector&
ssh i0$1.zubops.com -L $2:10.100.23.$1:$2 -L $port2:10.100.23.$1:$port2 -N 
