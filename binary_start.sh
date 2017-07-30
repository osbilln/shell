#!/bin/bash
. /etc/profile
java -Xmx128m -ea -Denv=stage -javaagent:/opt/binary_core/spring-instrument-3.0.0.RELEASE.jar -jar /opt/binary_core/binary.jar 
