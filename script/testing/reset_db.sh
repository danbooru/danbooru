#!/usr/bin/env bash

bundle exec rake db:drop db:create
bundle exec rake db:migrate
bundle exec rake db:seed
