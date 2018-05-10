set :output, "/var/log/whenever.log"
env "MAILTO", "webmaster@danbooru.donmai.us"

every 1.hour do
  runner "UploadErrorChecker.new.check!"
end

every 1.hour do
  runner "DelayedJobErrorChecker.new.check!"
end

every 1.day do
  runner "DailyMaintenance.new.run"
end

every 1.day, :at => "1:00 am" do
  command "psql --set statement_timeout=0 -hdbserver -c \"vacuum analyze;\" danbooru2"
end

every 1.week, :at => "1:30 am" do
  runner "WeeklyMaintenance.new.run"
end

every 1.month, :at => "2:00 am" do
  runner "MonthlyMaintenance.new.run"
end
