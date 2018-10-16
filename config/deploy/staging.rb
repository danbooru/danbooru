set :user, "danbooru"
set :rails_env, "staging"
server "testbooru.donmai.us", :roles => %w(web app db), :primary => true, :user => "danbooru"

set :linked_files, fetch(:linked_files, []).push(".env.staging")
set :rbenv_path, "/home/danbooru/.rbenv"
set :deploy_to, "/var/www/danbooru2"
