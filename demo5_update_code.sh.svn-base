cd /home/spt/demo5
chmod 777 -R .
#revert all local changes
svn revert -R .
#remove all unversioned files
svn status --no-ignore | grep '^\?' | sed 's/^\?      //'  | xargs -Ixx rm -rf xx
svn update
cd /home/spt/demo5/cron
./run_zf_script.sh deploy_tools.php
cd /home/spt/demo5
chmod 777 -R .
