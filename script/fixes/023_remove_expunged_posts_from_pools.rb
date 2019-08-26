#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

live_post_ids = Post.order("id asc").all(:select => "id").map(&:id)
all_post_ids = (1..live_post_ids.last).to_a
dead_post_ids = all_post_ids - live_post_ids

dead_post_ids.each do |post_id|
  Pool.where("post_ids like '? %' or post_ids like '% ? %' or post_ids like '% ?'", post_id, post_id, post_id).find_each do |pool|
    pool.update(post_ids: pool.remove_number_from_string(post_id, pool.post_ids), post_count: pool.post_count - 1)
  end
end
