set statement_timeout = 0;
delete from posts where id < 1140000;
delete from post_appeals where post_id < 1140000;
vacuum analyze;
