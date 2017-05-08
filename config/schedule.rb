set :output, "/var/log/whenever.log"

every 1.hour do
  runner "UploadErrorChecker.new.check!"
end

every 1.day do
  runner "DailyMaintenance.new.run"
end

every 1.day, :at => "1:00 am" do
  # command "cd /var/www/danbooru2/current ; script/donmai/backup_db"
  # command "cd /var/www/danbooru2/current ; bundle exec ruby script/donmai/backup_db_to_s3"
  # command "cd /var/www/danbooru2/current ; script/donmai/prune_backup_dbs"
  # command "psql --set statement_timeout=0 -hdbserver -c \"vacuum analyze;\" danbooru2"
end

every 1.week, :at => "1:30 am" do
  runner "WeeklyMaintenance.new.run"
end

every 1.month, :at => "2:00 am" do
  runner "MonthlyMaintenance.new.run"
end

if environment == "production"
  every 30.minutes do
    runner "PostUpdate.push"
  end

  # every 1.hour do
  #   runner "AmazonBackup.execute"
  # end
end
