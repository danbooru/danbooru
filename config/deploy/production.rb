set :user, "danbooru"
set :rails_env, "production"
server "kagamihara", :roles => %w(web app db), :primary => true
server "shima", :roles => %w(web app)
server "saitou", :roles => %w(web app)
server "oogaki", :roles => %w(worker)

set :linked_files, fetch(:linked_files, []).push(".env.production")
set :rbenv_path, "/home/danbooru/.rbenv"