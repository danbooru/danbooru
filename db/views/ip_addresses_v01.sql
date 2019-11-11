  SELECT 'ArtistVersion' AS model_type, id AS model_id, updater_id AS user_id, updater_ip_addr AS ip_addr, created_at
  FROM artist_versions
UNION ALL
  SELECT 'ArtistCommentaryVersion', id, updater_id, updater_ip_addr, created_at
  FROM artist_commentary_versions
UNION ALL
  SELECT 'Comment', id, creator_id, creator_ip_addr, created_at
  FROM comments
UNION ALL
  SELECT 'Dmail', id, from_id, creator_ip_addr, created_at
  FROM dmails
UNION ALL
  SELECT 'NoteVersion', id, updater_id, updater_ip_addr, created_at
  FROM note_versions
UNION ALL
  SELECT 'Post', id, uploader_id, uploader_ip_addr, created_at
  FROM posts
UNION ALL
  SELECT 'User', id, id, last_ip_addr, created_at
  FROM users
  WHERE last_ip_addr IS NOT NULL
UNION ALL
  SELECT 'WikiPageVersion', id, updater_id, updater_ip_addr, created_at
  FROM wiki_page_versions
