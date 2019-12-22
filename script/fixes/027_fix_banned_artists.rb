#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

CurrentUser.without_safe_mode do
  Artist.where(:is_banned => true).find_each do |artist|
    Post.tag_match(artist.name).where(:is_banned => false).find_each do |post|
      post.ban!
    end

    Post.tag_match(artist.name).where(:is_deleted => true).find_each do |post|
      reasons = post.flags.map(&:reason)
      unless reasons.any? {|x| x =~ /Unapproved in three days/}
        post.undelete!
      end
    end
  end
end
