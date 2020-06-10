#!/usr/bin/bash -eu
# Used as an entrypoint by the Docker image to prepare the test database before running the test suite.

setup_database() {
  RAILS_ENV=test bin/rails db:test:prepare
}

# create the post_versions and pool_versions tables needed by the test suite.
setup_archives() {
  mkdir ~/archives
  cd ~/archives
  git clone https://github.com/evazion/archives .
  gem install bundler -v 1.13.3
  bundle install --binstubs
  RAILS_ENV=test bin/rake db:migrate
}

setup_database
setup_archives
