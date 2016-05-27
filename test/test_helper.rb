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

  def upload_zip(path)
    upload_file(path, "application/zip", File.basename(path))
  end
end

class ActiveSupport::TestCase
  include UploadTestMethods

  def setup_vcr
    @record = false

    if @record
      # %x(find test/fixtures/vcr_cassettes -name '*pixiv*' -delete)
      # %x(find test/fixtures/vcr_cassettes -name '*ugoira*' -delete)
      # %x(find test/fixtures/vcr_cassettes -name '*seiga*' -delete)
      # %x(find test/fixtures/vcr_cassettes -name '*twitter*' -delete)
      # %x(find test/fixtures/vcr_cassettes -name '*artist*' -delete)
    end

    # instead of trying to persist these across tests just clear it out every time
    Cache.delete("pixiv-phpsessid")
    Cache.delete("pixiv-papi-access-token")
    Cache.delete("nico-seiga-session")
    Cache.delete("twitter-api-token")

    unless @record
      [:pixiv_login, :pixiv_password, :tinami_login, :tinami_password, :nico_seiga_login, :nico_seiga_password, :pixa_login, :pixa_password, :nijie_login, :nijie_password, :twitter_api_key, :twitter_api_secret].each do |key|
        Danbooru.config.stubs(key).returns("SENSITIVE")
      end
    end
  end
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
  
  def fetch key, expiry = 0, raw = false
    if @memory.has_key?(key)
      @memory[key]
    else
      @memory[key] = yield
    end
    @memory[key]
  end

  def incr key
    @memory[key] += 1
  end

  def decr key
    @memory[key] -= 1
  end

  def set key, value, expiry = 0
    @memory[key] = value
  end

  def get key
    @memory[key]
  end

  def delete key, delay = 0
    @memory.delete key
  end

  def get_multi *keys
    Hash[[keys.map{ |key| [key, @memory[key]] }]]
  end
end

if defined?(MEMCACHE)
  Object.send(:remove_const, :MEMCACHE)
end

MEMCACHE = MockMemcache.new

VCR.configure do |c|
  c.cassette_library_dir = "test/fixtures/vcr_cassettes"
  c.hook_into :webmock
  # c.allow_http_connections_when_no_cassette = true

  c.default_cassette_options = {
    match_requests_on: [
      :method,
      VCR.request_matchers.uri_without_param(:PHPSESSID)
    ]
  }
end
