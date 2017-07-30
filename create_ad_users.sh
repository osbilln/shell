i=1

while [ $i -lt 16000 ]
do
	echo "dsadd user \"cn=Totvs User$i,cn=Users,dc=totvs-lab,dc=local\" -samid totvsUser$i -ln User$i -fn Totvs$i -display \"Totvs User$i\" -upn totvsUser$i@totvs-lab.local -mustchpwd no -email suresh_user$i@blahblah.com -pwd Foobar1!" 
	i=`expr $i + 1`;
done


