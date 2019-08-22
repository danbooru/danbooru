# this is used in config/environments/production.rb.
env "RAILS_LOG_TO_STDOUT", "true"

set :output, "log/whenever.log"

every 1.hour do
  rake "maintenance:hourly"
end

every 1.day do
  rake "maintenance:daily"
end

every 1.week, :at => "1:30 am" do
  rake "maintenance:weekly"
end
