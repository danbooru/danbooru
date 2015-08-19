# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include tasks from other gems included in your Gemfile
require 'capistrano/rbenv'
require 'capistrano/rails'
require 'whenever/capistrano'
require 'capistrano3/unicorn'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

after "delayed_job:stop", "delayed_job:kill"
after "deploy:symlink:shared", "symlink:local_files"
after "deploy:symlink:shared", "symlink:directories"
before "deploy:started", "web:disable"
before "deploy:started", "delayed_job:stop"
after "deploy:published", "delayed_job:start"
after "deploy:published", "unicorn:reload"
after "deploy:published", "web:enable"
