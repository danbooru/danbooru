# Define cronjobs using the clockwork gem; see https://github.com/Rykian/clockwork.
# Use `bin/rails danbooru:cron` to start the cron process.
#
# See also `app/logical/danbooru_maintenance.rb`.

module Clockwork
  # Touch a heartbeat file every minute so that Kubernetes knows we're alive and running.
  if Rails.env.production?
    every(1.minute, "heartbeat") do
      File.write("tmp/danbooru-cron-heartbeat.txt", Time.now.utc.to_s + "\n")
    end
  end

  every(1.hour, "hourly", at: "**:00") do
    DanbooruMaintenance.hourly
  end

  every(1.day, "daily", at: "00:00") do
    DanbooruMaintenance.daily
  end

  every(1.week, "weekly", at: "Sunday 00:00") do
    DanbooruMaintenance.weekly
  end

  # XXX every 1.month will vary the day it runs on based on when the cron container starts.
  # Doing it this way means it will only run on the first day of the month.
  every(1.day, "monthly", at: "00:00", if: lambda { |t| t.day == 1 }) do
    DanbooruMaintenance.monthly
  end
end
