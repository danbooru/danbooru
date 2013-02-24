set statement_timeout = 0;
update posts set fav_count = (select count(*) from favorites _ where _.post_id = posts.id) where posts.created_at > '2013-02-01';
