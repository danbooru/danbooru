require "tasks/newrelic" if defined?(NewRelic)

namespace :maintenance do
  desc "Run hourly maintenance jobs"
  task hourly: :environment do
    DanbooruMaintenance.hourly
  end

  desc "Run daily maintenance jobs"
  task daily: :environment do
    DanbooruMaintenance.daily
  end

  desc "Run weekly maintenance jobs"
  task weekly: :environment do
    DanbooruMaintenance.weekly
  end

  desc "Run monthly maintenance jobs"
  task monthly: :environment do
    DanbooruMaintenance.monthly
  end
end
