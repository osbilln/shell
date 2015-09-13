#!/bin/bash
cd /home/srini/databasebackups/uat_backups
./fullBackupNew citiuat_staging
./fullBackupNew statefarmuat
./fullBackupNew statefarmuattest
