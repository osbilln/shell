#!/bin/bin
# func-ind.sh

echo_var ()
	{
	echo $1
	}
message=Hello
Hello=Goodbye

echo_var "$message"
echo_var "${!message}"
echo "-----------------"
Hello="Hello, Again!"
echo_var "$message"
echo_var "${!message}"

exit 0