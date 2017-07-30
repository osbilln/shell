#!/bin/sh
#
# This script will get two arguments, the full path to the working dir of the 
# current publish bundle and the delimiter being used.
#
# Make sure you make the script executable!  chmod +x scriptname
#
# The script should return non-zero to indicate error.  The last line of 
# output will be added to the job error message.
#
echo "Working dir is $1" > $1/exampleScriptRan
echo "Delimiter is '$2'" >> $1/exampleScriptRan
