#!/usr/bin/env bash

bundle exec rake db:drop db:create
bundle exec rake db:migrate
bundle exec rake db:seed

# dropdb danbooru2
# createdb danbooru2
# psql danbooru2 < db/danbooru1.struct.sql
# psql danbooru2 < script/upgrade_schema.sql
