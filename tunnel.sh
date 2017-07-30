#!/bin/sh

echo "ssh j000$1.zubops.com -L $2:localhost:$2 -N"
ssh j000$1.zubops.com -L $2:localhost:$2 -N
