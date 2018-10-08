require "tasks/newrelic" if defined?(NewRelic)

namespace :maintenance do
  desc "Run hourly maintenance jobs"
  task hourly: :environment do
    Maintenance.hourly
  end

  desc "Run daily maintenance jobs"
  task daily: :environment do
    Maintenance.daily
  end

  desc "Run weekly maintenance jobs"
  task weekly: :environment do
    Maintenance.weekly
  end
end
