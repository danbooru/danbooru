#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  CurrentUser.scoped(User.system) do
    ModerationReport.find_each do |report|
      if report.invalid? && report.errors[:model] == ["must exist"]
        puts "destroying modreport ##{report.id}"
        report.destroy!
      end
    end
  end
end
