#!/bin/sh

# i=1
# x=""
out=`awk '{print $19}' add_16k_users.bat`

# while [ $x -lt $out ]
for x in $out 
do
	echo "java SetPersonalPassword http://suresh1.fluigidentity.com:8080/cloudpass $x >> output  2>&1 &" 
	# i=`expr $i + 1`;
done


