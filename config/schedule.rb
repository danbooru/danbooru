# This file is used by the `whenver` gem to generate a crontab that runs
# Danbooru's maintenance tasks.
#
# @see app/logical/danbooru_maintenance.rb
# @see https://github.com/javan/whenever

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
