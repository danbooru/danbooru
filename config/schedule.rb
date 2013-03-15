set :output, "/var/log/whenever.log"

every 4.hours do
  runner "TagSubscription.process_all"
end

every 1.hour do
  runner "UploadErrorChecker.new.check!"
end

every 1.day do
  runner "DailyMaintenance.new.run"
end

every 1.day, :at => "1:00 am" do
  command "cd /var/www/danbooru2/current ; script/donmai/backup_db"
  command "cd /var/www/danbooru2/current ; bundle exec ruby script/donmai/backup_db_to_s3"
  command "cd /var/www/danbooru2/current ; script/donmai/prune_backup_dbs"
end

every 1.day, :at => "2:00 am" do
  command "psql --set statement_timeout=0 -hdbserver -c \"vacuum analyze verbose;\" danbooru2"
end

if environment == "production"
  every 1.hour do
    runner "AmazonBackup.execute"
  end
  
  every 1.week do
    runner "UserPasswordResetNonce.prune!"
  end
end
