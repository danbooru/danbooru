#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  # Fix posts that have a non-zero fav_count but no favorites.
  records = Post.where("fav_count != 0").where.not(id: Favorite.select(:post_id).distinct)
  puts "Fixing #{records.size} records"
  records.update_all(fav_count: 0)
end

with_confirmation do
  # Fix posts that have a fav_count inconsistent with the favorites table.
  records = Post.find_by_sql(<<~SQL.squish)
    UPDATE posts
    SET fav_count = true_count
    FROM (
      SELECT post_id, COUNT(*) AS true_count
      FROM favorites
      GROUP BY post_id
    ) true_counts
    WHERE posts.id = post_id AND posts.fav_count != true_count
    RETURNING posts.*
  SQL
  puts "Fixing #{records.size} records"
end
