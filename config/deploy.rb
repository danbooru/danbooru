# This file contains configuration settings for deploying Danbooru to the
# production servers using Capistrano. This is only used by production and
# shouldn't be edited by end users.
#
# @see Capfile
# @see config/deploy
# @see lib/capistrano/tasks
# @see https://capistranorb.com

set :stages, %w(production test)
set :default_stage, "test"
set :application, "danbooru"
set :repo_url,  "git://github.com/danbooru/danbooru.git"
set :deploy_to, "/var/www/danbooru2"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle"
set :branch, ENV.fetch("branch", "master")

# skip migrations if files in db/migrate weren't modified
set :conditionally_migrate, true

# run migrations on the primary app server
set :migration_role, :app

set :whenever_roles, :cron

# how long unicorn:legacy_restart (used by deploy:rolling) waits until killing the old unicorn.
set :unicorn_restart_sleep_time, 10
