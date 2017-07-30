# replace mysql_admin with admin's id and admin_password with admin's password before running this script
# NOTE: no space between -u and admin's id, and no space between -p and admin's password
mysql -u{mysql_admin} -p{admin_password} -f mysql <<EOF
DROP USER socialapi;
DROP DATABASE IF EXISTS socialapi;
FLUSH PRIVILEGES;
EOF
