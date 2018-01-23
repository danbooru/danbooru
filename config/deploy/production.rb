set :user, "albert"
set :rails_env, "production"
server "sonohara.donmai.us", :roles => %w(web app db), :primary => true, :user => "albert"
server "hijiribe.donmai.us", :roles => %w(web app), :user => "albert"

set :linked_files, fetch(:linked_files, []).push(".env.production")
set :rbenv_path, "/home/albert/.rbenv"