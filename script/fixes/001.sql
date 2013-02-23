set statement_timeout = 0;
update posts set is_pending = false where is_deleted = true and is_pending = true;
update posts set last_commented_at = null where last_commented_at is not null and not exists (select 1 from comments _ where _.post_id = posts.id limit 1);
