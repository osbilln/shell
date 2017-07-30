#!/bin/bash
# set -x
### Check for last client update
### 

function checknewCompany {
        ###  knife node show "$companyId"."$domainName" -l | grep companyStatus
        knife node show "$companyId"."$domainName"
        
}

function addrunList {
        knife node run_list add "$companyId"."$domainName" "role[$companyId]"
}

function cleanup {
        cd /data/virtualappliance/
	if [  -e /data/virtualapplianceprocessed/$companyId ]; then
           rm $companyId $companyId.conf /data/virtualappliance/$companyId
        else 
           mv $companyId $companyId.conf /data/virtualapplianceprocessed/
        fi
}

cd /data/virtualappliance
find *.conf -type f | while read f; do
     cd /data/virtualappliance
     companyId=`cat ${f} | grep companyId | awk '{print $2}'`
     echo $companyId
     adminEmail=`cat ${f} | grep adminEmail | awk '{print $2}'`
     echo $adminEmail
     domainName=`cat ${f} | grep adminEmail | awk '{print $2}' | cut -d\@ -f2`
     echo $domainName

     echo "Checking if the new host has registered"
     cd /data/chefrepo
     checknewCompany
     if [ $? -eq 0 ]; then
     	echo "new client has registered , assigning runlist now"
        addrunList
        echo "Show $company runlist"
       	knife node show "$companyId"."$domainName"
        
        echo "Clean Up processed hosts"
       	cleanup
     fi
done
