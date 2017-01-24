set :rails_env, "staging"
server "testbooru.donmai.us", :roles => %w(web app db), :primary => true, :user => "danbooru"

set :linked_files, fetch(:linked_files, []).push(".env.staging")
