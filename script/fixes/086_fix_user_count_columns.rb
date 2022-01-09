#!/usr/bin/env ruby

require_relative "base"

def fix_favorite_count!
  with_confirmation do
    # Fix users that have a non-zero favorite_count but no favorites.
    records = User.where("favorite_count != 0").where.not(id: Favorite.select(:user_id).distinct)
    puts "Fixing #{records.size} records"
    records.update_all(favorite_count: 0)
  end

  with_confirmation do
    # Fix users that have a favorite_count inconsistent with the favorites table.
    records = User.find_by_sql(<<~SQL.squish)
      UPDATE users
      SET favorite_count = true_count
      FROM (
        SELECT user_id, COUNT(*) AS true_count
        FROM favorites
        GROUP BY user_id
      ) true_counts
      WHERE users.id = user_id AND users.favorite_count != true_count
      RETURNING users.*
    SQL
    puts "Fixing #{records.size} records"
  end
end

def fix_post_upload_count!
  with_confirmation do
    # Fix users that have a non-zero post_upload_count but no posts.
    records = User.where("post_upload_count != 0").where.not(id: Post.select(:uploader_id).distinct)
    puts "Fixing #{records.size} records"
    records.update_all(post_upload_count: 0)
  end

  with_confirmation do
    # Fix users that have a post_upload_count inconsistent with the posts table.
    records = User.find_by_sql(<<~SQL.squish)
      UPDATE users
      SET post_upload_count = true_count
      FROM (
        SELECT uploader_id, COUNT(*) AS true_count
        FROM posts
        GROUP BY uploader_id
      ) true_counts
      WHERE users.id = uploader_id AND users.post_upload_count != true_count
      RETURNING users.*
    SQL
    puts "Fixing #{records.size} records"
  end
end

def fix_note_update_count!
  with_confirmation do
    # Fix users that have a non-zero note_update_count but no note updates.
    records = User.where("note_update_count != 0").where.not(id: NoteVersion.select(:updater_id).distinct)
    puts "Fixing #{records.size} records"
    records.update_all(note_update_count: 0)
  end

  with_confirmation do
    # Fix users that have a note_update_count inconsistent with the note_versions table.
    records = User.find_by_sql(<<~SQL.squish)
      UPDATE users
      SET note_update_count = true_count
      FROM (
        SELECT updater_id, COUNT(*) AS true_count
        FROM note_versions
        GROUP BY updater_id
      ) true_counts
      WHERE users.id = updater_id AND users.note_update_count != true_count
      RETURNING users.*
    SQL
    puts "Fixing #{records.size} records"
  end
end

def fix_unread_dmail_count!
  with_confirmation do
    # Fix users that have a non-zero unread_dmail_count but no unread dmails.
    records = User.where("unread_dmail_count != 0").where.not(id: Dmail.active.unread.select(:owner_id).distinct)
    puts "Fixing #{records.size} records"
    records.update_all(unread_dmail_count: 0)
  end

  with_confirmation do
    # Fix users that have an unread_dmail_count inconsistent with the dmails table.
    records = User.find_by_sql(<<~SQL.squish)
      UPDATE users
      SET unread_dmail_count = true_count
      FROM (
        SELECT owner_id, COUNT(*) AS true_count
        FROM dmails
        WHERE is_read = false AND is_deleted = false
        GROUP BY owner_id
      ) true_counts
      WHERE users.id = owner_id AND users.unread_dmail_count != true_count
      RETURNING users.*
    SQL
    puts "Fixing #{records.size} records"
  end
end

fix_favorite_count!
fix_post_upload_count!
fix_note_update_count!
fix_unread_dmail_count!
