set :rails_env, "staging"
server "danbooru.rori-dl.com", :roles => %w(web app db), :primary => true, :user => "danbooru"
