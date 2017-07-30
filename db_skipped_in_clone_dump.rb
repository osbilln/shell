#!/usr/bin/ruby

if ARGV.count != 6
  puts "db_skipped_in_clone_dump.rb usage: <db_name> <db_host> <db_user> <db_pw> <dump dir> <bucket location>"
  exit
end

DB_NAME = ARGV[0]
DB_HOST = ARGV[1]
DB_USER = ARGV[2]
DB_PW = ARGV[3]
DUMP_DIR = ARGV[4]
S3_BUCKET = ARGV[5]

puts "#{DB_NAME} #{DB_HOST} #{DB_USER} #{DB_PW} #{DUMP_DIR} #{S3_BUCKET}"
ALL_TABLES = `echo "show tables from #{DB_NAME};" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`

LOOKUPS = `echo "select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id = df.id JOIN INFORMATION_SCHEMA.TABLES it on it.TABLE_NAME = dl.tablename and it.TABLE_SCHEMA='${SET_CLONE_DB_STAGING_NAME}' where dl.type not in ('DATA_FILE') and df.purpose = 'LOOKUP_LIST' UNION select distinct tablename from N_DATA_LISTS dl join N_DATA_FEEDS df on dl.datafeed_id = df.id JOIN INFORMATION_SCHEMA.TABLES it on it.TABLE_NAME = dl.tablename and it.TABLE_SCHEMA='${SET_CLONE_DB_STAGING_NAME}' where dl.type not in ('DATA_FILE', 'TMP', 'STAGING', 'EXTENSION') and df.purpose = 'DATA_LIST'" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`
NAEHAS_TABLES = `echo "show tables where tables_in_#{DB_NAME} like 'N\_%' and tables_in_#{DB_NAME} not like 'N\_DATA\_MAPPINGS%';" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s `
VIEWS = `echo "select table_name from INFORMATION_SCHEMA.tables where table_type = 'VIEW' and table_schema = '#{DB_NAME}'" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s`  
ACL_TABLES = `echo "show tables where tables_in_#{DB_NAME} like 'acl_%';" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s `
ENVERS_AUDIT_TABLES = `echo "show tables where tables_in_#{DB_NAME} like '%\_aud' and tables_in_#{DB_NAME} not like 'N\_%';" | mysql -uroot -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} -A -s `

TABLES_DUMPED_IN_CLONE = "#{NAEHAS_TABLES} #{ENVERS_AUDIT_TABLES} #{ACL_TABLES} #{LOOKUPS} #{VIEWS}"

TABLES_TO_IGNORE = ""
TABLES_DUMPED_IN_CLONE.split.each do |table|
  TABLES_TO_IGNORE << "--ignore-table=#{DB_NAME}." << table + " " 
end


#puts "Backing up #{DB_NAME} : #{TABLES_TO_IGNORE}"

if TABLES_TO_IGNORE.split.count > 2000
  TABLES_TO_IGNORE1 = ""
  TABLES_TO_IGNORE2 = "" 
  cnt = 0
  TABLES_TO_IGNORE.split.each do |ignore_table|
    if cnt < 1000
      TABLES_TO_IGNORE1 << "#{ignore_table} "
    else
      TABLES_TO_IGNORE2 << "#{ignore_table} "
    end 
    cnt += 1
  end
  puts "Dumping to #{DUMP_DIR}/#{DB_NAME}_skipped1.sql.gz"
  `mysqldump --single-transaction --quick --flush-logs --master-data -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} #{TABLES_TO_IGNORE1} | gzip -1 >  #{DUMP_DIR}/#{DB_NAME}_skipped1.sql.gz`
  puts "Dumping to #{DUMP_DIR}/#{DB_NAME}_skipped2.sql.gz"
  `mysqldump --single-transaction --quick --flush-logs --master-data -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} #{TABLES_TO_IGNORE2} | gzip -1 >  #{DUMP_DIR}/#{DB_NAME}_skipped2.sql.gz`
else
  puts "Dumping to #{DUMP_DIR}/#{DB_NAME}_skipped.sql.gz"
  `mysqldump --single-transaction --quick --flush-logs --master-data -u #{DB_USER} -p#{DB_PW} -h #{DB_HOST} #{DB_NAME} #{TABLES_TO_IGNORE} | gzip -1 >  #{DUMP_DIR}/#{DB_NAME}_skipped.sql.gz`
end
#puts "copying to $S3_BUCKET"
#`s3cmd --force put #{DUMP_DIR}/#{DB_NAME}_skipped.sql.gz s3://$S3_BUCKET/#{DB_NAME}_skipped.sql.gz`

#puts "dump #{DB_NAME} to S3 complete" #, removing local dump file"
#rm -f #{DUMP_DIR}/#{DB_NAME}.sql.gz
