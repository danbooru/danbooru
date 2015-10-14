set :user, "danbooru"
set :rails_env, "production"
server "danbooru.rori-dl.com", :roles => %w(web app db), :primary => true, :user => "danbooru"
