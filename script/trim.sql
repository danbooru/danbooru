set statement_timeout = 0;
delete from posts where id < (select max(id) - 50000 from posts);
delete from post_appeals where post_id < (select max(id) - 50000 from posts);
vacuum analyze;
