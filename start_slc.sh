#!/bin/bash
# nohup java -Xmx128m -ea -Denv=stage -javaagent:/opt/service_locator_core/spring-instrument-3.0.0.RELEASE.jar -jar /opt/service_locator_core/service_locator.jar & 
. /etc/profile
java -Xmx128m -ea -Denv=stage -javaagent:$SLC_HOME/spring-instrument-3.0.0.RELEASE.jar -jar $SLC_HOME/service_locator.jar 
