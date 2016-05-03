#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

n = 1
max = Post.maximum(:id)
interval = 10_000

while n <= max
  all = n.upto(n + interval).to_a
  present = Post.where("id between ? and ?", n, n + interval).pluck(:id)
  missing = present - ids
  missing.each do |x|
    if x <= max
      puts "expunging #{x}"
      Post.remove_iqdb(x)
    end
  end

  n += interval
  max = Post.maximum(:id)
end
