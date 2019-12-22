#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

CurrentUser.without_safe_mode do
  sample_tags = %w(pixiv_manga_sample pixiv_thumbnail deviantart_thumbnail thumbnail nico_nico_thumbnail twitpic_thumbnail tumblr_sample imageboard_sample nijie_sample)
  Post.tag_match(sample_tags.map {|tag| "~" + tag}.join(" ")).where("is_deleted = true and parent_id is not null and fav_count > 0").find_each do |post|
    if (post.parent.tag_array & sample_tags).any?
      next
    else
      post.give_favorites_to_parent
    end
  end
end
