#!/bin/bash
. /etc/profile
java -Xmx128m -javaagent:/opt/data_access_core/spring-instrument-3.0.0.RELEASE.jar -Denv=stage -jar /opt/data_access_core/data_access.jar

