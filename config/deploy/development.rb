set :user, "danbooru"
set :rails_env, "development"
server "localhost", :roles => %w(web app db), :primary => true, :user => "danbooru"
