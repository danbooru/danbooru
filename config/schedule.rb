set :output, "/var/log/whenever.log"

every 1.hour do
  TagSubscription.process_all
end

every 1.hour do
  AmazonBackup.execute
end
