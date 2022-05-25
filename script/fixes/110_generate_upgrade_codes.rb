#!/usr/bin/env ruby

require_relative "base"

5_000.times do
  code = UpgradeCode.create!(creator: User.system)
  puts "id=#{code.id} code=#{code.code}"
end
