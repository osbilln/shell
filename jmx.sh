
HOSTADDRESS=192.168.80.61
ARG1=1090
# /usr/local/nagios/libexec/check_jmx -U service:jmx:rmi://'$HOSTADDRESS$'/jndi/rmi://'$HOSTADDRESS$':'$ARG1$'/jmxrmi $ARG2$

./check_jmx -U service:jmx:rmi://$HOSTADDRESS/jndi/rmi://$HOSTADDRESS:$ARG1/jmxrmi 
