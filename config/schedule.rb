set :output, "/var/log/whenever.log"
#env "MAILTO", "webmaster@danbooru.donmai.us"

every 1.hour do
  rake "maintenance:hourly"
end

every 1.day do
  rake "maintenance:daily"
end

every 1.week, :at => "1:30 am" do
  rake "maintenance:weekly"
end
