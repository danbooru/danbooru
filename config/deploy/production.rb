set :user, "danbooru"
set :rails_env, "production"
server "192.168.2.192", :roles => %w(web app db), :primary => true
# server "", :roles => %w(web app)
# server "", :roles => %w(web app)
server "192.168.2.192", :roles => %w(worker)

set :linked_files, fetch(:linked_files, []).push(".env.production")
set :rbenv_path, "/home/danbooru/.rbenv"
