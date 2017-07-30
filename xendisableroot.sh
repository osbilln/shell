#!/bin/bash 
# Run install as root
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

users=("billn" "srini" "randyb" "robertj" "issacl")

# Create admin group 
getent group xen_admins > /dev/null
if [[ $? != 0 ]]; then
/usr/sbin/groupadd xen_admins
echo "%xen_admins	ALL=(ALL)	ALL" >> /etc/sudoers
else
echo "This server has already been configured"
exit 0
fi

# Set starter password to qwer1234
for user in ${users[@]}; do
/usr/sbin/useradd $user -G xen_admins
/usr/sbin/usermod -a -G xen_admins $user
/usr/sbin/usermod -a -G wheel $user
echo "$user:qwer1234" | /usr/sbin/chpasswd --md5 $user
done

#xe subject-list 2>1 | grep xen_admins 2>&1 > /dev/null
#if [[ $? != 0 ]]; then
#  # Remove existing (AD) auth pool
#  xe pool-disable-external-auth
#fi

# Set up PAM auth and disable remote root
xe subject-list | grep xen_admins >/dev/null
if [[ $? != 0 ]]; then
  xe pool-enable-external-auth auth-type=PAM service-name=auth
  UUID=`xe subject-add subject-name=xen_admins`
  xe subject-role-add role-name=pool-admin uuid=$UUID
  passwd -d root
  sed -i 's/authconfig is run./authconfig is run.\nauth required pam_securetty.so\nauth required  pam_unix.so nullok/' /etc/pam.d/system-auth
fi
