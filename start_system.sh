#!/bin/bash
. /etc/profile
java -Xms128m -Xmx128m -javaagent:/opt/system_core/spring-instrument-3.0.0.RELEASE.jar -ea -Denv=stage -jar /opt/system_core/system.jar

