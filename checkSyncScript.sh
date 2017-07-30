#!/bin/sh

for D in /usr/java/staging/*/scripts/sync-instance ; do
	grep -L mail $D
done
