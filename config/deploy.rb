set :stages, %w(production development staging)
set :default_stage, "development"
set :application, "danbooru"
set :repo_url,  "git://github.com/GlassedSilver/danbooru.git"
set :scm, :git
set :deploy_to, "/var/www/danbooru"
set :rbenv_ruby, "2.5.1"
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle')
set :branch, ENV.fetch("branch", "master")
