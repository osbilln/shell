#!/bin/bash
##-------------------------------------------------------------------
## File : crontab_check.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-07-10>
## Updated: Time-stamp: <2014-07-11 22:46:02>
##-------------------------------------------------------------------
# crontab: */5 * * * * /Users/mac/server-check/code/shell-check/crontab_check.sh 2>&1 >> /var/log/crontab-check.log

email_list=${1:-"filebat.mark@gmail.com denny.zhang001@gmail.com"}
server_list="172.20.16.12 172.20.16.18 172.20.16.13 172.20.16.15 172.20.16.11 172.20.16.23 172.20.18.13"

function mail_by_msmtp(){
    recipient_email=${1?}
    subject=${2?}
    content=${3?}
    cat <<EOF | msmtp $recipient_email
Subject: $subject

"$content"
EOF

}

date=`date +%Y-%m-%d_%H:%M`
has_error=false
output_str=""
output_str="${output_str}"`date +['%Y-%m-%d %H:%M:%S']`" Tests Begins\n"

for server in ${server_list[*]}; do
    output=`curl http://$server:9281 2>/dev/null`
    if [ $? -ne 0 ]; then
        has_error=true
        output_str="${output_str}Error to run: curl http://$server:9281\n"
    else
        if (echo "$output" | grep -i error 1>/dev/null); then
            has_error=true
            output_str="${output_str}========== Check $server failed ==========\n"
            output_str="${output_str}${output}\n"
        fi;
    fi;
done;

output_str="${output_str}"`date +['%Y-%m-%d %H:%M:%S']`" Tests end\n"
if $has_error ; then
    output_str=$(echo "$output_str" | sed -e 's/<br\/>//g') 
    output_str=$(echo "$output_str" | sed -e 's/http:\/\//http:\/\/ /g')
    mail_by_msmtp "$email_list" "[$date] Health Check Of Fluig Servers Has Failed" "${output_str}"
else 
    output_str="${output_str}All tests has passes.\nTests are performed on: $server_list\n"
fi;
echo -e "$output_str"
## File : crontab_check.sh ends
