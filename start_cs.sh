#!/bin/bash

#export JBOSS_HOME=/opt/jboss
#export PATH=/usr/lunasa/bin:/usr/lunasa/jsp/lib:$PATH

# export CLASSPATH=/usr/lunasa/jsp/lib/LunaProvider.jar:$CLASSPATH

# export JBOSS_CLASSPATH=/usr/lunasa/jsp/lib/LunaProvider.jar

# export JAVA_OPTS="-verbose"

# export JAVA_HOME=usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0.x86_64

rm -f /opt/jboss/server/se_tsm/log/*

rm -f nohup.out


# nohup bin/run.sh -b0.0.0.0 -c se_tsm -Djboss.service.binding.set=ports-01 2>/dev/null &

# note - the ports-01 i believe is an index to 8180 where 01 is or'd onto 8080 - not positive

# nohup bin/run.sh -c se_tsm -Djboss.service.binding.set=ports-01 -b0.0.0.0 -Dhibernate.dialect=org.hibernate.dialect.MySQLDialect &

# export JBOSS_ENDORSED_DIRS=/usr/lunasa/jsp/lib/LunaProvider.jar

nohup /opt/jboss/bin/run.sh -c se_tsm -b0.0.0.0 &
