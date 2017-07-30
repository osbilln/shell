#!/bin/bash
. /etc/profile
java -Xmx64m -Denv=stage  -jar /opt/data_import/dw_util.jar
