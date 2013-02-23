set statement_timeout = 0;
update posts set is_flagged = false where is_deleted = true and is_flagged = true;
