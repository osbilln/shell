#!/bin/bash
trap exit ERR
. ./couchdb.properties

source function.bsh

host="https://$username:$password@$server"

path=`pwd`
current_date_time=$(date +"%Y-%m-%d-%T")
current_date=$(date +"%Y-%m-%d")

access=`curl -s $host`

[[ "${access:2:5}" == "error" ]] &&
logMessage "$access" && exit 1

fileData=`cat id.json`

for i in $fileData; do
logMessage $i
len=${#i}
c=${i:`expr index "$i" =`:$len}
d=${i:0:`expr index "$i" =`-1}

dbresponse=`curl -X GET $host/$d`

if [[ "${dbresponse:2:5}" == "error" ]];then
logMessage "Database $d not Present so creating database"
create_database_res=`curl -X PUT $host/$d`
else
logMessage "Database $d is Present "
while :
do
     ### User Input Option###
    echo -e "\n\t Type yes to continue\n\t Type no to Delete and create a new database"
        read option
         case $option in
       yes) logMessage "User has Selected yes"
	        break ;;
       no) logMessage "User has Selected no"
		   logMessage "Deleting & Creating of $d database is Started"
		   del_database_res=`curl -X DELETE $host/$d`
		   logMessage "Delete Response is $del_database_res of $d database"
           create_database_res=`curl -X PUT $host/$d`
		   logMessage "Create Response is $create_database_res of $d database"
		   logMessage "Deleting & Creating of $d database is Completed"
           break ;;
     esac
done
fi
#checking Document is present or Not
logMessage "Checking Document in database"
arr=$(echo "$c" | tr "," "\n")
for x in $arr
do
db=`curl -X GET $host/$d/$x`
if [[ "${db:2:5}" == "error" ]];then
logMessage "Document ID $x of $d Database not Present,so creating $x document"

if [[ "$x" != "_design"* ]];then
file=$x.json
response=`curl -X POST $host/$d/_bulk_docs -H"Content-Type:application/json"  -d @$path/$d/$file`
logMessage "Create $x doc response is $response"
else
file="view.json"
response=`curl -X POST $host/$d/_bulk_docs -H"Content-Type:application/json"  -d @$path/$d/$file`
logMessage "Create $x doc response is $response"
fi
else
logMessage "Document ID $x of $d Database Present,so taking backup of $x document"
logMessage "Taking Backup of Document $x Started"
create_directory $wrapper_script_path/backup-$current_date/CouchDB/$d
if [[ "$x" != "_design"* ]];then
file=$x.json
else
file="view.json"
fi
echo "$db" >> $wrapper_script_path/backup-$current_date/CouchDB/$d/$file
rename $wrapper_script_path/backup-$current_date/CouchDB/$d  $wrapper_script_path/backup-$current_date/CouchDB/$d $file $file-$current_date_time 
logMessage "Taking Backup of Document $x Completed"

docarr=$(echo "$db" | tr "," "\n")
for r in $docarr
do
if [[ "$r" == \"_rev\"* ]]
then
logMessage "Revision of $d and $x doc is $r"
id=$(IFS=:;set -- $(echo "$r") ;echo $2)
rev="${id//\"/}"
logMessage "Deleting of Document $x Started"
delresponse=`curl -X DELETE $host/$d/$x?rev=$rev`
logMessage "Delete  response of $x is $delresponse"
logMessage "Deleting of Document $x Completed"
logMessage "Creating of Document $x Started"
response=`curl -X POST $host/$d/_bulk_docs -H"Content-Type:application/json"  -d @$path/$d/$file`
logMessage "Create  response of $x is $response"
logMessage "Creating of Document $x Completed"
fi
done
fi
done
done
logMessage "========================================Setting Up Couchdb DB & Data Completed==============================="
cd ../..
bash Wrapper.bsh