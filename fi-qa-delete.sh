#!/bin/bash
# arglist.sh
# Invoke this script with several arguments, such as "one two three" ...

#    -A, --aws-access-key-id KEY      Your AWS Access Key ID
#    -K SECRET,                       Your AWS API Secret Access Key
#        --aws-secret-access-key
#    -N, --node-name NAME             The name of the node and client to delete, if it differs from the server name.  Only has meaning when used with the '--purge' option.
#    -s, --server-url URL             Chef Server URL
#    -k, --key KEY                    API Client Key
#        --[no-]color                 Use colored output, defaults to false on Windows, true otherwise
#    -c, --config CONFIG              The configuration file to use
#        --defaults                   Accept default values for all questions
#    -d, --disable-editing            Do not open EDITOR, just accept the data as is
#    -e, --editor EDITOR              Set the editor to use for interactive commands
#    -E, --environment ENVIRONMENT    Set the Chef environment
#    -F, --format FORMAT              Which format to use for output
#    -u, --user USER                  API Client Username
#        --print-after                Show the data after a destructive operation
#    -P, --purge                      Destroy corresponding node and client on the Chef Server, in addition to destroying the EC2 node itself.  Assumes node and client have the same name as the server (if not, add the '--node-name' option).
#        --region REGION              Your AWS region
#    -V, --verbose                    More verbose output. Use twice for max verbosity
#    -v, --version                    Show chef version
#    -y, --yes                        Say yes to all prompts for confirmation
#    -h, --help                       Show this message


E_BADARGS=85

if [ ! -n "$1" ]
then
  echo "Usage: `basename $0` image-01 image-02 etc."
  exit $E_BADARGS
fi

echo
index=1          # Initialize count.

echo "Listing args with \"\$@\":"
for arg in "$@"
 do
  echo "Arg #$index = $arg"
  let "index+=1"
  knife ec2 server delete $arg --region us-east-1
 done             # $@ sees arguments as separate words.
