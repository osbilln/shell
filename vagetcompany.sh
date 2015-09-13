#!/bin/bash
set -x
### Check for last client update
### 

function log() {
    local msg=${1?} >> $LOG_FILE
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n" >> "$LOG_FILE"
}

function getcompanyData {
	cd /cloudpass/backend/build/bin
	java -jar ../dist/VABuildScript.jar $companyId $adminEmail /data/virtualappliance/$companyId
}

function createcookbook {
	COOKBOOKS=/root/.chef/chefrepo/cookbooks
	cd $COOKBOOKS
	cp -r fi-va-default $companyId
	cp -r /data/virtualappliance/$companyId/user /root/.chef/chefrepo/cookbooks/$companyId/templates/default/user.erb
	cp -r /data/virtualappliance/$companyId/company-user /root/.chef/chefrepo/cookbooks/$companyId/templates/default/company-user.erb
	cp -r /data/virtualappliance/$companyId/company /root/.chef/chefrepo/cookbooks/$companyId/templates/default/company.erb
	cd /root/.chef/chefrepo
	knife cookbook upload "$companyId"

}

function createrole {
	cd /root/.chef/chefrepo/role
	cp -r fi-va-default.rb $companyId.rb
	sed -i "s@fi-va-default@$companyId@g" $companyId.rb
	knife role from file $companyId.rb
}

function addrunList {
	knife node run_list add "$companyId"."$domainName" "role[$companyId]"
}

function findnewcompany {
	cd /data/virtualappliance
	find . -type f -mtime -10 | while read f; do
        # if backup file already exist, restore it
        if [ -e ${f}.local ]; then
            cp ${f}.local $f
        fi
        sed -e '89 s/false/true/g' ${f} > ${f}.0
        sed -e 's|\/tmp|\/data\/|' ${f}.0 > ${f}.1
        sed -e 's|\/data\/logs\/|\/data\/fluigidentity-logs\/|' ${f}.1 > ${f}.2
        mv ${f}.2 ${f}
        # backup the file
        rm ${f}.1
        cp ${f} ${f}.local
    done
}

function checknewCompany {
	cd ~/.chef/
	status=`knife node show "$companyId"."$domainName" -l | grep companyStatus`
	if [ $status -eq  1 ]; then
		exit 1
	fi
}

function cleanupappServer {
	ssh $hostName -C "rm $company_conf/*.conf "
}

function cleanup {
	cd /data/virtualappliance/
		mv $companyId $companyId.conf /data/virtualapplianceprocessed/
}

hostName=mv-fi-dev-01
cd /data/virtualappliance
company_conf="/var/www/cloudpass/data/virtualappliance"

ssh $hostName -C "find $company_conf -type f -mmin -15 -exec ls -l {} \; "

if [ $? -ne 0 ]; then
		exit 0
else

	if [ ! -e /data/virtualappliance/ ]; then
		mkdir /data/virtualappliance/
	fi

	scp -rp $hostName:$company_conf/*.conf /data/virtualappliance
	
	find *.conf -type f | while read f; do
		companyId=`cat ${f} | grep companyId | awk '{print $2}'`
		echo $companyId
		adminEmail=`cat ${f} | grep adminEmail | awk '{print $2}'`
		domainName=`cat ${f} | grep adminEmail | awk '{print $2}' | cut -d\@ -f2`
		echo $adminEmail
	cd /cloudpass/backend/build/bin
	java -jar ../dist/VABuildScript.jar "$companyId" "$adminEmail" /data/virtualappliance/"$companyId"

	cd ~/.chef/chefrepo
	createcookbook
	createrole

	# addrunList
	
	cleanupappServer
	done
fi	

### End of vagetcompnay.sh