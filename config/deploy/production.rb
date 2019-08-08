set :user, "danbooru"
set :rails_env, "production"
set :rbenv_path, "/home/danbooru/.rbenv"
append :linked_files, ".env.production"

server "kagamihara", :roles => %w(web app), :primary => true
server "shima", :roles => %w(web app)
server "saitou", :roles => %w(web app)
server "oogaki", :roles => %w(worker)

after "deploy:finished", "newrelic:notice_deployment"
