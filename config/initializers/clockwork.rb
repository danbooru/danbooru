# Define cronjobs using the clockwork gem; see https://github.com/Rykian/clockwork.
# Use `bin/rails danbooru:cron` to start the cron process.
#
# See also `app/logical/danbooru_maintenance.rb`.

module Clockwork
  # Touch a heartbeat file every minute so that health checks can tell we're alive and processing cronjobs.
  every(1.minute, "heartbeat") do
    File.write("tmp/danbooru-cron-heartbeat.txt", Time.now.utc.to_s + "\n")
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

  # `every(1.month, ...)` fires `period` after the job's last run,
  # so a cron container restart resets it and can trigger the monthly
  # job on any day (danbooru/danbooru#5435).
  # Run this daily instead and only execute on the first of the month.
  every(1.day, "monthly", at: "00:00", if: ->(t) { t.day == 1 }) do
    DanbooruMaintenance.monthly
  end
end
