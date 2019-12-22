#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

PostReplacement.where("created_at > ?", 6.months.ago).find_each do |pr|
  post = pr.post
  if post.has_preview?
    puts "queuing for #{post.id}"
    Post.iqdb_sqs_service.send_message("update\n#{post.id}\n#{post.preview_file_url}")
  end
end
