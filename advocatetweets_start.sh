#!/bin/bash
. /etc/profile
java -Xmx128m -ea -Denv=stage -javaagent:$ADVOCATE_TWEETS_HOME/spring-instrument-3.0.0.RELEASE.jar -jar $ADVOCATE_TWEETS_HOME/advocate_tweets.jar 
