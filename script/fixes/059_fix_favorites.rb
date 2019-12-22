#!/usr/bin/env ruby

require_relative "../../config/environment"

def fix_favorites
  Favorite.without_timeout do
    # delete favorites with a nonexistent post_id
    Favorite.where("NOT EXISTS (SELECT 1 FROM posts WHERE posts.id = favorites.post_id)").delete_all
  end
end

def fix_migrations
  ApplicationRecord.connection.execute("DELETE FROM scheme_migrations WHERE version = '201704142336170'")
end
