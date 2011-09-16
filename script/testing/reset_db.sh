#!/usr/bin/env bash

rake db:drop db:create
createlang plpgsql danbooru2
rake db:migrate
rake db:seed
