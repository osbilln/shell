cd /root/mysql_backup/
mysqldump -unaehas -p1234rty7890 --all-databases > prodmergedb2-all-databases_`date +%F-%H-%M`.sql
gzip *.sql
find . -mtime +8 -name 'prodmergedb2-all*.sql.gz' | xargs rm
