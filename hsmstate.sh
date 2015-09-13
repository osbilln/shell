# $Id: prod/ethsm/jhsm/src/examples/hsmstate.sh 1.1.1.1 2011/04/28 13:38:18EDT Sorokine, Joseph (jsorokine) Exp  $
# $Author: Sorokine, Joseph (jsorokine) $
#
# Copyright (c) 2000 ERACOM Pty Ltd
# All Rights Reserved - Proprietary Information of ERACOM Pty. Ltd.
# Not to be Construed as a Published Work.
#
# $Source: prod/ethsm/jhsm/src/examples/hsmstate.sh $
# $Revision: 1.1.1.1 $
# $Date: 2011/04/28 13:38:18EDT $

#!/bin/sh

NAME=hsmstate
JAR=$LD_LIBRARY_PATH/jhsm.jar

echo ============================================
echo This sample illustrates the $NAME command
echo implemented via JHSM library.
echo ============================================

$JDK/bin/javac -classpath $JAR $NAME.java 
$JDK/bin/java  -classpath $JAR:`pwd` $NAME $1 $2 $3 $4 $5
