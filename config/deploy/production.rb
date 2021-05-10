set :user, "danbooru"
set :rails_env, "production"
set :delayed_job_workers, 8
append :linked_files, ".env.production"

server "kagamihara", :roles => %w(web app cron), :primary => true
server "shima", :roles => %w(web app)
server "saitou", :roles => %w(web app)
server "oogaki", :roles => %w(worker)

set :newrelic_appname, "Danbooru"
after "deploy:finished", "newrelic:notice_deployment"
