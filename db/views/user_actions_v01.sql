  SELECT 'ArtistVersion'::character varying AS model_type, id AS model_id, updater_id AS user_id, 'create'::character varying AS event_type, created_at AS event_at
  FROM artist_versions
UNION ALL
  SELECT 'ArtistCommentaryVersion', id, updater_id, 'create', created_at
  FROM artist_commentary_versions
UNION ALL
  SELECT 'Ban', id, user_id, 'subject', created_at
  FROM bans
UNION ALL
  SELECT 'BulkUpdateRequest', id, user_id, 'create', created_at
  FROM bulk_update_requests
UNION ALL
  SELECT 'Comment', id, creator_id, 'create', created_at
  FROM comments
UNION ALL
  SELECT 'CommentVote', id, user_id, 'create', created_at
  FROM comment_votes
UNION ALL (
  SELECT 'Dmail', id, from_id, 'create', created_at
  FROM dmails
  WHERE from_id != owner_id
  ORDER BY created_at DESC
)
UNION ALL
  SELECT 'FavoriteGroup', id, creator_id, 'create', created_at
  FROM favorite_groups
UNION ALL
  SELECT 'ForumPost', id, creator_id, 'create', created_at
  FROM forum_posts
UNION ALL
  SELECT 'ForumPostVote', id, creator_id, 'create', created_at
  FROM forum_post_votes
UNION ALL
  SELECT 'ForumTopic', id, creator_id, 'create', created_at
  FROM forum_topics
UNION ALL
  SELECT 'ModAction', id, creator_id, 'create', created_at
  FROM mod_actions
UNION ALL
  SELECT 'ModerationReport', id, creator_id, 'create', created_at
  FROM moderation_reports
UNION ALL
  SELECT 'NoteVersion', id, updater_id, 'create', created_at
  FROM note_versions
UNION ALL
  SELECT 'Post', id, uploader_id, 'create', created_at
  FROM posts
UNION ALL
  SELECT 'PostAppeal', id, creator_id, 'create', created_at
  FROM post_appeals
UNION ALL
  SELECT 'PostApproval', id, user_id, 'create', created_at
  FROM post_approvals
UNION ALL
  SELECT 'PostDisapproval', id, user_id, 'create', created_at
  FROM post_disapprovals
UNION ALL
  SELECT 'PostFlag', id, creator_id, 'create', created_at
  FROM post_flags
UNION ALL
  SELECT 'PostReplacement', id, creator_id, 'create', created_at
  FROM post_replacements
UNION ALL
  SELECT 'PostVote', id, user_id, 'create', created_at
  FROM post_votes
UNION ALL
  SELECT 'SavedSearch', id, user_id, 'create', created_at
  FROM saved_searches
UNION ALL
  SELECT 'TagAlias', id, creator_id, 'create', created_at
  FROM tag_aliases
UNION ALL
  SELECT 'TagImplication', id, creator_id, 'create', created_at
  FROM tag_implications
UNION ALL (
  SELECT 'TagVersion', id, updater_id, 'create', created_at
  FROM tag_versions
  WHERE updater_id IS NOT NULL
  ORDER BY created_at DESC
) UNION ALL
  SELECT 'Upload', id, uploader_id, 'create', created_at
  FROM uploads
UNION ALL
  SELECT 'User', id, id, 'create', created_at
  FROM users
UNION ALL
  SELECT 'UserEvent', id, user_id, 'create', created_at
  FROM user_events
UNION ALL
  SELECT 'UserFeedback', id, creator_id, 'create', created_at
  FROM user_feedback
UNION ALL
  SELECT 'UserFeedback', id, user_id, 'subject', created_at
  FROM user_feedback
UNION ALL (
  SELECT 'UserUpgrade', id, purchaser_id, 'create', created_at
  FROM user_upgrades
  WHERE status IN (20, 30)
  ORDER BY created_at DESC
) UNION ALL
  SELECT 'UserNameChangeRequest', id, user_id, 'create', created_at
  FROM user_name_change_requests
UNION ALL
  SELECT 'WikiPageVersion', id, updater_id, 'create', created_at
  FROM wiki_page_versions
