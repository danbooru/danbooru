ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Dir[File.expand_path(File.dirname(__FILE__) + "/factories/*.rb")].each {|file| require file}

module UploadTestMethods
  def upload_file(path, content_type, filename)
  	tempfile = Tempfile.new(filename)
  	FileUtils.copy_file(path, tempfile.path)
  	(class << tempfile; self; end).class_eval do
  		alias local_path path
  		define_method(:tempfile) {self}
  		define_method(:original_filename) {filename}
  		define_method(:content_type) {content_type}
  	end
  	
  	tempfile
  end

  def upload_jpeg(path)
  	upload_file(path, "image/jpeg", File.basename(path))
  end
end

class ActiveSupport::TestCase
  include UploadTestMethods
end

class ActionController::TestCase
  include UploadTestMethods
  
  def assert_authentication_passes(action, http_method, role, params, session)
    __send__(http_method, action, params, session.merge(:user_id => @users[role].id))
    assert_response :success
  end
  
  def assert_authentication_fails(action, http_method, role)
    __send__(http_method, action, params, session.merge(:user_id => @users[role].id))
    assert_redirected_to(new_sessions_path)
  end
end

class MockMemcache
  def initialize
    @memory = {}
  end

  def flush_all
    @memory = {}
  end

  def set key, value, expiry = 0
    @memory[key] = value
  end

  def get key
    @memory[key]
  end

  def delete key, delay
    @memory.delete key
  end

  def get_multi *keys
    Hash[[keys.map{ |key| [key, @memory[key]] }]]
  end
end

silence_warnings do
  MEMCACHE = MockMemcache.new
end
