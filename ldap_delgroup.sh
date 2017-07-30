#!/bin/sh

# Delete the group specified on the command line from the ldap database. This
# will also remove all users from the removed group.

# make sure a valid group was supplied
group=$1
if [ -z $group ]; then
    echo "Usage: $0 group name" 1>&2
    exit 1
elif ! getent group | grep -q ^$group: &>/dev/null; then
    echo "Group $group does not exist." 1>&2
    exit 1
fi

# put the ldif needed in a temporary file
tmp=`mktemp`
echo "cn=$group,ou=Group,dc=ldap,dc=example,dc=org" > $tmp

ldapdelete -x -D "cn=admin,dc=ldap,dc=example,dc=org" -f $tmp \
    -y /etc/ldap.secret

rm $tmp

echo "Group $group and its list of members have been removed."
