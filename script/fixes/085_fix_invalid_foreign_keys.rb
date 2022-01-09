#!/usr/bin/env ruby

require_relative "../../config/environment"

ApplicationRecord.transaction do
  Favorite.left_outer_joins(:post).where("posts.id": nil).destroy_all
  ArtistVersion.left_outer_joins(:artist).where("artists.id": nil).destroy_all
  Dmail.left_outer_joins(:owner).where("users.id": nil).destroy_all
  ForumTopicVisit.left_outer_joins(:user).where("users.id": nil).destroy_all
  NoteVersion.left_outer_joins(:post).where("posts.id": nil).destroy_all
  Upload.where(parent_id: 0).update(parent_id: nil)

  print "Commit? (yes/no): "
  raise "abort" unless STDIN.readline.chomp == "yes"
end
