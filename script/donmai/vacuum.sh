#!/bin/sh

psql -h dbserver <<EOF
set statement_timeout = 0;
vacuum analyze posts;
vacuum analyze tags;
vacuum analyze users;
vacuum analyze favorites;
vacuum analyze comments;
EOF
