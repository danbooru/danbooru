# Define cronjobs using the clockwork gem; see https://github.com/Rykian/clockwork.
# Use `bin/rails danbooru:cron` to start the cron process.
#
# See also `app/logical/danbooru_maintenance.rb`.

module Clockwork
  every(1.hour, "hourly", at: "**:00") do
    DanbooruMaintenance.hourly
  end

  every(1.day, "daily", at: "00:00") do
    DanbooruMaintenance.daily
  end

  every(1.week, "weekly", at: "Sunday 00:00") do
    DanbooruMaintenance.weekly
  end

  every(1.month, "monthly", at: "00:00") do
    DanbooruMaintenance.monthly
  end
end
