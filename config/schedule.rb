set :output, "/var/log/whenever.log"

every 1.hour do
  TagSubscription.process_all
end

if fetch(:whenever_environment) == "production"
  every 1.hour do
    AmazonBackup.execute
  end
end
