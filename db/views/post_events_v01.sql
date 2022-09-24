  SELECT 'Post'::character varying AS model_type, id AS model_id, id AS post_id, uploader_id AS creator_id, created_at AS event_at
  FROM posts
UNION ALL
  SELECT 'PostAppeal'::character varying, id, post_id, creator_id, created_at
  FROM post_appeals
UNION ALL
  SELECT 'PostApproval'::character varying, id, post_id, user_id, created_at
  FROM post_approvals
UNION ALL
  SELECT 'PostDisapproval', id, post_id, user_id, created_at
  FROM post_disapprovals
UNION ALL
  SELECT 'PostFlag', id, post_id, creator_id, created_at
  FROM post_flags
UNION ALL
  SELECT 'PostReplacement', id, post_id, creator_id, created_at
  FROM post_replacements
