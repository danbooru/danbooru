namespace :app do
  set :rolling_deploy, false

  before "deploy:migrate", "app:disable"
  after "deploy:published", "app:enable"

  task :disable do
    if fetch(:rolling_deploy)
      # do nothing
    else
      invoke "web:disable"
      invoke "unicorn:terminate"
    end
  end

  task :enable do
    if fetch(:rolling_deploy)
      invoke "unicorn:legacy_restart"
    else
      invoke "unicorn:start"
      invoke "web:enable"
    end
  end
end

namespace :deploy do
  desc "Deploy a rolling update without taking the site down for maintenance"
  task :rolling do
    set :rolling_deploy, true
    invoke "deploy"
  end
end
