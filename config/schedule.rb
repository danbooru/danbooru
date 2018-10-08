set :output, "/var/log/whenever.log"
#env "MAILTO", "webmaster@danbooru.donmai.us"

every 1.hour do
  runner "Maintenance.hourly"
end

every 1.day do
  runner "Maintenance.daily"
end

every 1.day, :at => "1:00 am" do
  command "psql --set statement_timeout=0 -h inuyama -c \"vacuum analyze;\" danbooru2"
end

every 1.week, :at => "1:30 am" do
  runner "Maintenance.weekly"
end
