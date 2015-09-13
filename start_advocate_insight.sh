#!/bin/bash
. /etc/profile
java -Xmx128m -javaagent:/opt/advocate_insight_core/spring-instrument-3.0.0.RELEASE.jar -Denv=stage -jar /opt/advocate_insight_core/advocate_insight.jar 
