#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------------------
# Start Script for the CATALINA Server
#
# $Id: startup.sh 562770 2007-08-04 22:13:58Z markt $
# -----------------------------------------------------------------------------

# Better OS/400 detection: see Bugzilla 31132
os400=false
darwin=false
case "`uname`" in
CYGWIN*) cygwin=true;;
OS400*) os400=true;;
Darwin*) darwin=true;;
esac

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`

## BEGIN Customizations
# Only set CATALINA_HOME if not already set
[ -z "$CATALINA_HOME" ] && CATALINA_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`

# Enable JMX
export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=40653 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

# Configure CXF logging to use log4j
CXF_LOGGING="-Dorg.apache.cxf.Logger=org.apache.cxf.common.logging.Log4jLogger"

# Add $DEBUG to java_opts to enable remote debugging.
DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=6888"
if [ -f ../base-dashboard.properties ] ; then
  . ../base-dashboard.properties
fi

# Set memory settings
if [ -f $CATALINA_HOME/bin/memOpts.env ] ; then
    # memOpts.env should contain a line like:
    # MEM_OPTS="-Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m"
    . $CATALINA_HOME/bin/memOpts.env
else
    MEM_OPTS="-Xmx${MAX_MEM:-2048m} -XX:PermSize=${MAX_PERM_MEM:-256m} -XX:MaxPermSize=${MAX_PERM_MEM:-256m}"
fi
echo "Using MEM_OPTS=$MEM_OPTS"

JAVA_OPTS=" -server $MEM_OPTS -Djava.awt.headless=true -noverify "
JAVA_OPTS="${JAVA_OPTS} -javaagent:${CATALINA_HOME}/lib/aspectjweaver.jar "
JAVA_OPTS="${JAVA_OPTS} ${CXF_LOGGING}"

export JAVA_OPTS
### END Customizations

export CATALINA_PID=catalina.pid

EXECUTABLE=catalina.sh

# Check that target executable exists
if $os400; then
  # -x will Only work on the os400 if the files are:
  # 1. owned by the user
  # 2. owned by the PRIMARY group of the user
  # this will not work if the user belongs in secondary groups
  eval
else
  if [ ! -x "$PRGDIR"/"$EXECUTABLE" ]; then
    echo "Cannot find $PRGDIR/$EXECUTABLE"
    echo "This file is needed to run this program"
    exit 1
  fi
fi

exec "$PRGDIR"/"$EXECUTABLE" start "$@"
