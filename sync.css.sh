#! /bin/bash
redundancy_interface=`./sync1.css | grep "Redundancy interface" | awk '{print $3}'`
if [[ $redundancy_interface = 1.1.1.1 ]]; then
                echo redundancy address $redundancy_interface means we are connected to primary CSS which is the current master
		./sync2.css > ./sync2.out
		sync_status=`grep "Config Sync" ./sync2.out | awk '{print $3}' | cut -c 1-10`
		if [[ $sync_status = Successful ]]; then
			 mail -s "CSS Sync Status from primary to secondary is $sync_status" ops@naehas.com < sync2.out
		else
			 mail -s "PROBLEM: CSS Sync Status from primary to secondary is $sync_status" ops@naehas.com < sync2.out
		fi
else
	if [[ $redundancy_interface = 1.1.1.2 ]]; then
                echo redundancy address $redundancy_interface means we are connected to secondary CSS which is the current master
		./sync3.css > ./sync3.out
		sync_status=`grep "Config Sync" ./sync3.out | awk '{print $3}' | cut -c 1-10`
		if [[ $sync_status = Successful ]]; then
			 mail -s "CSS Sync Status from secondary to primary is $sync_status" ops@naehas.com < sync3.out
		else
			 mail -s "PROBLEM: CSS Sync Status from secondary to primary is $sync_status" ops@naehas.com < sync3.out
		fi
	fi
fi
