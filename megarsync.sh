#!/bin/sh

useable=1
cron=0

[ -z $1 ] && useable=0
[ -z $2 ] && useable=0
[ -z $3 ] && useable=0
[ -z $4 ] && useable=0
[ -z $5 ] && useable=0
[ -z $6 ] && useable=0
[ ! -z $7 ] && [ "$7" = "cron" ] && cron=1

localpath=$1
depth=$2
rsyncs=$3
rsyncopts=$4
userandhost=$5
remotepath=$6

if [ ! -d $localpath ]; then
        echo "$localpath does not exist"
        useable=0
fi

if [ "$useable" = "0" ]; then
        echo -n $(basename $0)
        echo " localpath depth rsyncs rsyncopts userandhost remotepath [cron]"
        exit 1;
fi

pid=${0}.pid
tmpdir=/tmp/rsync.$$

[ -e $pid ] && exit 0;

trap 'rm -f $pid >/dev/null 2>&1; rm -rf $tmpdir >/dev/null 2>&1;' 0
trap 'exit 2' 1 2 3 15

echo $$ > $pid
mkdir $tmpdir

regex=""
for i in $(jot - 1 $depth); do
        regex="$regex[^/]*/"
done

find $localpath -maxdepth $depth -type d | grep "$regex" > $tmpdir/dirlist
total=$(wc -l $tmpdir/dirlist|cut -d\/ -f1|tr -d ' ')
n=$(expr $total / $rsyncs)

if [ "$total" = "0" ]; then
        echo "No directories to sync.";
        exit 1;
fi

offset=$n
i=0
while true; do
        tail=$(expr $total + $n - $offset)
        if [ $tail -gt $n ]; then
                tail=$n
        fi
        head -n $offset $tmpdir/dirlist | tail -n $tail > $tmpdir/$i.dirlist
        c=$(wc -l $tmpdir/$i.dirlist|cut -d\/ -f1|tr -d ' ')
        if [ "$c" = "0" ]; then
                rm $tmpdir/$i.dirlist
                break
        elif [ $c -lt $n ]; then
                break
        fi
        i=$(expr $i + 1)
        offset=$(expr $offset + $n)
done

for i in $(jot - 1 $rsyncs); do
        echo "while read r; do ssh $userandhost \"mkdir -p $remotepath\$r\" ; done < $tmpdir/$i.dirlist &"
done
for i in $(jot - 1 $rsyncs); do
        echo "while read r; do /usr/local/bin/rsync $rsyncopts \$r $userandhost:$remotepath\$r 2>&1 | tee $tmpdir/$i.dirlist.log ; done < $tmpdir/$i.dirlist &"
done

if [ $cron = "0" ]; then
        doit=0
        while true; do
                read -p "Do you wish to procede?" yn
                case $yn in
                        [Yy]* )  doit=1; break;;
                        [Nn]* )  doit=0; break;;
                        * ) echo "Please answer yes or no.";;
                esac
        done
fi

if [ "$doit" = "0" ]; then
        exit 0;
fi

for i in $(jot - 1 $rsyncs); do
        while read r; do ssh $userandhost "mkdir -p $remotepath$r" ; done < $tmpdir/$i.dirlist &
done
wait
for i in $(jot - 1 $rsyncs); do
        while read r; do /usr/local/bin/rsync $rsyncopts $r $userandhost:$remotepath$r 2>&1 | tee $tmpdir/$i.dirlist.log ; done < $tmpdir/$i.dirlist &
done
wait

echo -n "Parent megarsync ended at "
date
