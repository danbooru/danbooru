#!/usr/bin/env bash

bundle exec rake db:drop db:create
createlang plpgsql danbooru2
bundle exec rake db:migrate
bundle exec rake db:seed
