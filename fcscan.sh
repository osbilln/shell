for x in `ls /sys/class/fc_host`; do echo
"1" > /sys/class/fc_host/$x/issue_lip; echo "- - -" > /sys/class/scsi_host/$x/scan; done
