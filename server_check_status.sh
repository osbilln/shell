##-------------------------------------------------------------------
## File : fluig-server-check.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description :
## --
## Created : <2014-07-10>
## Updated: Time-stamp: <2014-07-12 15:10:30>
##-------------------------------------------------------------------
# crontab: */5 * * * * /home/denny/server-check/fluig-server-check.sh 2>&1 >> /var/log/fluig-server-check.log

email_list=${1:-"filebat.mark@gmail.com denny.zhang@totvs.com"}
#email_list=${1:-"denny.zhang@totvs.com"}

#server_list="172.20.18.13 172.20.16.14 172.20.16.12 172.20.16.17 172.20.16.18 172.20.16.13 172.20.16.15 172.20.16.16 172.20.16.11 172.21.16.11 172.21.16.12 172.20.16.19 172.20.16.20 172.20.16.23 172.20.16.26 172.20.18.15 172.20.18.16"

server_list=""

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
## File : fluig-server-check.sh ends

