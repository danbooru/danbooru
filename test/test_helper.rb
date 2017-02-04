ENV["RAILS_ENV"] = "test"

if ENV["SIMPLECOV"]
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter ".bundle"
    add_filter "script/"
    add_filter "test/"
    add_filter "config/"
  end
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'cache'

Dir[File.expand_path(File.dirname(__FILE__) + "/factories/*.rb")].each {|file| require file}

if defined?(MEMCACHE)
  Object.send(:remove_const, :MEMCACHE)
end

MEMCACHE = MemcacheMock.new
Delayed::Worker.delay_jobs = false
