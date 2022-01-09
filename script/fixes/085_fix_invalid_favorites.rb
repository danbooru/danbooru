#!/usr/bin/env ruby

require_relative "../../config/environment"

Favorite.transaction do
  Favorite.left_outer_joins(:post).where("posts.id": nil).destroy_all

  print "Commit? (yes/no): "
  raise "abort" unless STDIN.readline.chomp == "yes"
end
