#!/bin/sh

# Delete the user specified on the command line from the ldap database. Note
# that the user's home directory is not removed, nor is the user removed from
# any groups.

# make sure a valid user was supplied
user=$1
if [ -z $user ]; then
    echo "Usage: $0 username" 1>&2
    exit 1
elif ! getent passwd | grep -q ^$user: &>/dev/null; then
    echo "User $user does not exist." 1>&2
    exit 1
fi

# put the ldif needed in a temporary file
tmp=`mktemp`
echo "uid=$user,ou=People,dc=ldap,dc=example,dc=org" > $tmp

ldapdelete -x -D "cn=admin,dc=ldap,dc=example,dc=org" -f $tmp \
    -y /etc/ldap.secret

rm $tmp

echo "User $user has been removed, but home directory has not been removed."
