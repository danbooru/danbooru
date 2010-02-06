ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'shoulda'
require 'factory_girl'
require 'mocha'
require 'faker'
require 'rails/test_help'

Dir[File.expand_path(File.dirname(__FILE__) + "/factories/*.rb")].each {|file| require file}

class ActiveSupport::TestCase
end
