#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  # Fix posts that have a tag_count_* column inconsistent with the true count.
  posts = Post.find_by_sql(<<~SQL.squish)
    UPDATE posts
    SET
      tag_count_general = true_tag_count_general,
      tag_count_artist = true_tag_count_artist,
      tag_count_copyright = true_tag_count_copyright,
      tag_count_character = true_tag_count_character,
      tag_count_meta = true_tag_count_meta,
      tag_count = true_tag_count
    FROM (
      SELECT
        posts.id AS post_id,
        COUNT(*) FILTER (WHERE category = 0) AS true_tag_count_general,
        COUNT(*) FILTER (WHERE category = 1) AS true_tag_count_artist,
        COUNT(*) FILTER (WHERE category = 3) AS true_tag_count_copyright,
        COUNT(*) FILTER (WHERE category = 4) AS true_tag_count_character,
        COUNT(*) FILTER (WHERE category = 5) AS true_tag_count_meta,
        COUNT(*) AS true_tag_count
      FROM
        posts,
        unnest(string_to_array(tag_string, ' ')) tag
      JOIN tags ON tags.name = tag
      GROUP BY posts.id
    ) tag_category_counts
    WHERE
      posts.id = tag_category_counts.post_id AND (
        posts.tag_count_general   != tag_category_counts.true_tag_count_general OR
        posts.tag_count_artist    != tag_category_counts.true_tag_count_artist OR
        posts.tag_count_copyright != tag_category_counts.true_tag_count_copyright OR
        posts.tag_count_character != tag_category_counts.true_tag_count_character OR
        posts.tag_count_meta      != tag_category_counts.true_tag_count_meta OR
        posts.tag_count           != tag_category_counts.true_tag_count
      )
    RETURNING posts.*
  SQL

  puts "Fixing #{posts.size} records"
end
