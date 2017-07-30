#!/bin/csh

foreach db (mpsp2 mpspprod mpsp2qa medco groupoqa2nd o2 naehasclean)
set dbPath = "/usr/java/"$db"-dashboard/bin"
cd $dbPath
echo Shutting down $dbPath
sh shutdown.sh
echo Starting up $dbPath
sh startup.sh
end
