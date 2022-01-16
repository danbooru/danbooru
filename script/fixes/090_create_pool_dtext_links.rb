#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  Pool.find_each do |pool|
    pool.update_dtext_links
  end
end
