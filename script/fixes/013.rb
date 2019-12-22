#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Comment.find_each do |comment|
  if !Post.exists?(comment.post_id)
    puts "deleting comment #{comment.id}"
    comment.destroy
  end
end; true

Ban.find_each do |ban|
  puts "updating ban for user #{ban.user.id}"
  ban.user.update_attribute(:is_banned, true)
end; true

ArtistVersion.update_all "is_banned = false"

Artist.where("is_banned = true").find_each do |artist|
  puts "updating artist #{artist.id}"
  artist.versions.last.update_column(:is_banned, true)
end; true

danbooru_conn = PGconn.connect(dbname: 'danbooru')
danbooru2_conn = PGconn.connect(dbname: "danbooru2")
danbooru_conn.exec("set statement_timeout = 0")
danbooru_conn.exec("SELECT * FROM comments WHERE id < 29130") do |result|
  result.each do |row|
    # puts row["id"], row["created_at"], row["post_id"], row["user_id"], row["body"], row["ip_addr"], row["score"]
    danbooru2_conn.exec "insert into comments (id, created_at, updated_at, post_id, creator_id, body, ip_addr, score, updater_id, updater_ip_addr) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)", [row["id"], row["created_at"], row["created_at"], row["post_id"], row["user_id"], row["body"], row["ip_addr"], row["score"], row["user_id"], row["ip_addr"]]
  end
end
