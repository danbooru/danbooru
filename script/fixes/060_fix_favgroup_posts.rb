#!/usr/bin/env ruby

require_relative "../../config/environment"

favgroups = FavoriteGroup.select("*, unnest(string_to_array(post_ids, ' '))::bigint AS post_id")
favgroups = FavoriteGroup.select("*").from(favgroups).where("NOT EXISTS (SELECT 1 FROM posts WHERE id = post_id)")

FavoriteGroup.transaction do
  favgroups.each do |favgroup|
    favgroup.remove!(favgroup.post_id)
  end
end
