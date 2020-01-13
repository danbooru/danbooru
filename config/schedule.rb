# this is used in config/environments/production.rb.
env "RAILS_LOG_TO_STDOUT", "true"

set :output, "log/whenever.log"

every :hour do
  rake "maintenance:hourly"
end

every :day do
  rake "maintenance:daily"
end

every :sunday do
  rake "maintenance:weekly"
end

every :month do
  rake "maintenance:monthly"
end
