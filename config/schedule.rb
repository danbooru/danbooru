set :output, "/var/log/whenever.log"

every 1.hour do
  TagSubscription.process_all
end
