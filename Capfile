# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
require 'capistrano/rbenv'
require 'capistrano/rails'
require 'whenever/capistrano'
require 'capistrano3/unicorn'
require 'capistrano/deploytags'
require 'new_relic/recipes'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

# workaround for https://github.com/capistrano/rails/issues/235
Rake::Task["deploy:assets:backup_manifest"].clear_actions
