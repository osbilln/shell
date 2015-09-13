!#/bin/bash

echo "Please enter your file name to check"
read filename
if [ -x "$filename" ]; then 
	echo "File $filename exists. "
	cp $filename $filename.bak
else
	echo "File $filename not found. "
	touch $filename
fi; echo "file test complete."
