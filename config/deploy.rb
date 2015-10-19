set :stages, %w(production development staging)
set :default_stage, "staging"
set :application, "danbooru"
set :repo_url,  "https://github.com/Iratu/danbooru.git"
set :scm, :git
set :deploy_to, "/var/www/danbooru2"
set :rbenv_ruby, "2.1.5"
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle')
