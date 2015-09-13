#!/bin/bash
jarpath=$(ls -1t ../dist/rest*.jar)
jarfile=$(basename $jarpath)

function kill_process {
    if [ $# -ge 1 ]; then
        p=$(ps aux | grep -i $1 | grep -v grep | awk '{print $2}')
        if [ "$p" != "" ]; then
            kill -15 $p
        else
            echo "can not find pattern \"$1\""
        fi
    fi
}

for f in $jarpath; do
  jarfile=$(basename $f)
  kill_process "$jarfile"
done

