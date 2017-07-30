#+begin_src sh
#!/bin/bash
##-------------------------------------------------------------------
## File : run_command_in_all_nodes.sh
## Author : Denny <denny.zhang001@gmail.com>
## Description : Run command in a list of servers.
##               Here we assume ssh key is properly uploaded, thus we 
##               don't need to input ssh password
## --
## Created : <2014-07-10>
## Updated: Time-stamp: <2014-07-31 14:10:04>
##-------------------------------------------------------------------

# Example1: Run a command in all nodes of prod env.
#    sh ./run_command_in_all_nodes.sh "ssh root@HOSTIP date"
#          Note: We assume ssh public key is uploaded properly
#          In above, HOSTIP will be replaced by server ip.
#
# Example2: Run a command in some nodes
#    sh ./run_command_in_all_nodes.sh "ssh root@HOSTIP date" "172.20.16.14 172.20.16.12"

command=${1:-"ssh root@HOSTIP date"}
server_list=${2:-"172.20.16.14 172.20.16.12 172.20.16.17 172.20.16.18 172.20.16.13 172.20.16.15 172.20.16.16 172.20.16.11 172.21.16.11 172.21.16.12 172.20.16.19 172.20.16.20 172.20.16.23 172.20.16.26 172.20.18.13 172.20.18.15 172.20.18.16"}

date=`date +%Y-%m-%d_%H:%M`
has_error=false
echo `date +['%Y-%m-%d %H:%M:%S']` "Actions Begin\n"

for server in ${server_list[*]}; do
    actual_command=`echo $command | sed "s/HOSTIP/$server/g"`
    echo "\n========== On $server Run: $actual_command =========="
    output=`$actual_command`
    if [ $? -ne 0 ]; then
        has_error=true
        echo "Error to run: $actual_command\n"
    else
        if (echo "$output" | grep -i error 1>/dev/null); then
            has_error=true
            echo "========== Action on $server failed =========="
        fi;
    fi;
    echo "${output}\n"
done;

echo `date +['%Y-%m-%d %H:%M:%S']`" Actions are done\n"
## File : run_command_in_all_nodes.sh ends
