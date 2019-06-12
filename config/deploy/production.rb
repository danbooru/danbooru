set :user, "danbooru"
set :rails_env, "production"
server "kagamihara", :roles => %w(192.168.2.176), :primary => true
server "shima", :roles => %w(192.168.2.176)
server "saitou", :roles => %w(192.168.2.176)
server "oogaki", :roles => %w(192.168.2.176)

set :linked_files, fetch(:linked_files, []).push(".env.production")
set :rbenv_path, "/home/danbooru/.rbenv"
