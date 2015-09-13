#!/bin/bash
set -x
### Check for last client update
### 


function log()
{
    local msg=${1?} >> $LOG_FILE
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n" >> "$LOG_FILE"
}

function checknewCompany {
	cd ~/.chef/
	knife node show "$companyId"."$domainName" -l | grep companyStatus
	if [ $? -ne 0 ]; then
		echo "customer has been registered yet, exit for now"
		exit 1
	fi	
}

function addrunlist {
	knife node run_list add "$companyId"."$domainName" "role[$companyId]"
}

function shownode {
	knife node show "$companyId"."$domainName"
}

function cleanup {
	cd /data/virtualappliance/
	mv $companyId $companyId.conf /data/virtualapplianceprocessed/
}

hostName=mv-fi-dev-01

cd /data/virtualappliance
log "Looking for New Company"
find *.conf -type f | while read f; do
		companyId=`cat ${f} | grep companyId | awk '{print $2}'`
		echo $companyId
		adminEmail=`cat ${f} | grep adminEmail | awk '{print $2}'`
		echo $adminEmail
		domainName=`cat ${f} | grep adminEmail | awk '{print $2}' | cut -d\@ -f2`
		echo $domainName
	
	log "Checking if the new host has registered"
	checknewCompany 	

	cd ~/.chef/chefrepo
	addrunlist

	log "Clean Up processed hosts"
	cleanup

 done
