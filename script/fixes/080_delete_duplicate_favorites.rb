#!/usr/bin/env ruby

require_relative "../../config/environment"

Favorite.transaction do
  0.upto(99) do |i|
    Favorite.where("user_id % 100 = #{i}").group(:post_id, :user_id).having("count(*) > 1").count.each do |(post_id, user_id), count|
      favs = Favorite.where(post_id: post_id, user_id: user_id).order(:id)

      # Remove all duplicates, leaving the oldest favorite.
      dupe_favs = favs.drop(1)
      puts "user_id=#{user_id} post_id=#{post_id} count=#{count} keep=#{favs.first.id} drop=#{dupe_favs.map(&:id).join(",")}"
      dupe_favs.each(&:delete)

      post = Post.find(post_id)
      post.update_columns(fav_count: post.favorites.count)

      user = User.find(user_id)
      user.update_columns(favorite_count: user.favorites.count)
    end
  end
end
