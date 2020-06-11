ENV["RAILS_ENV"] = "test"

if ENV["SIMPLECOV"]
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_group "Libraries", ["app/logical", "lib"]
    add_group "Presenters", "app/presenters"
  end
end

require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'cache'
require 'webmock/minitest'
require 'mocha/minitest'
require 'minitest/reporters'

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new)

Dir[File.expand_path(File.dirname(__FILE__) + "/factories/*.rb")].sort.each {|file| require file}
Dir[File.expand_path(File.dirname(__FILE__) + "/test_helpers/*.rb")].sort.each {|file| require file}

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

module TestHelpers
  def as(user, &block)
    CurrentUser.as(user, &block)
  end
end

class ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include FactoryBot::Syntax::Methods
  extend PostArchiveTestHelper
  extend PoolArchiveTestHelper
  include ReportbooruHelper
  include DownloadTestHelper
  include IqdbTestHelper
  include UploadTestHelper
  include TestHelpers

  mock_post_version_service!
  mock_pool_version_service!

  parallelize
  parallelize_setup do
    Rails.application.load_seed
  end

  setup do
    Socket.stubs(:gethostname).returns("www.example.com")
    mock_popular_search_service!
    mock_missed_search_service!
    WebMock.allow_net_connect!

    storage_manager = StorageManager::Local.new(base_dir: Dir.mktmpdir("uploads-test-storage-"))
    Danbooru.config.stubs(:storage_manager).returns(storage_manager)
    Danbooru.config.stubs(:backup_storage_manager).returns(StorageManager::Null.new)
  end

  teardown do
    FileUtils.rm_rf(Danbooru.config.storage_manager.base_dir)
    Cache.clear
  end
end

class ActionDispatch::IntegrationTest
  include TestHelpers
  extend PostArchiveTestHelper
  extend PoolArchiveTestHelper

  mock_post_version_service!
  mock_pool_version_service!

  def method_authenticated(method_name, url, user, **options)
    post session_path, params: { name: user.name, password: user.password }
    send(method_name, url, **options)
  end

  def get_auth(url, user, **options)
    method_authenticated(:get, url, user, **options)
  end

  def post_auth(url, user, **options)
    method_authenticated(:post, url, user, **options)
  end

  def put_auth(url, user, **options)
    method_authenticated(:put, url, user, **options)
  end

  def delete_auth(url, user, **options)
    method_authenticated(:delete, url, user, **options)
  end

  def setup
    super
    Socket.stubs(:gethostname).returns("www.example.com")

    ActionDispatch::IntegrationTest.register_encoder :xml, response_parser: ->(body) { Nokogiri.XML(body) }
  end

  def teardown
    super
    Cache.clear
  end
end

Rails.application.load_seed
