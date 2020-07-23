ENV["RAILS_ENV"] = "test"

require 'simplecov'
require_relative "../config/environment"
require 'rails/test_help'

Dir["#{Rails.root}/test/factories/*.rb"].sort.each { |file| require file }
Dir["#{Rails.root}/test/test_helpers/*.rb"].sort.each { |file| require file }

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new)
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

Rails.application.load_seed

class ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include FactoryBot::Syntax::Methods
  extend PostArchiveTestHelper
  extend PoolArchiveTestHelper
  include ReportbooruHelper
  include DownloadTestHelper
  include IqdbTestHelper
  include UploadTestHelper

  mock_post_version_service!
  mock_pool_version_service!

  parallelize
  parallelize_setup do |worker|
    Rails.application.load_seed

    SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
  end

  parallelize_teardown do |worker|
    SimpleCov.result
  end

  setup do
    Socket.stubs(:gethostname).returns("www.example.com")

    @temp_dir = Dir.mktmpdir("danbooru-temp-")
    storage_manager = StorageManager::Local.new(base_dir: @temp_dir)
    Danbooru.config.stubs(:storage_manager).returns(storage_manager)
    Danbooru.config.stubs(:backup_storage_manager).returns(StorageManager::Null.new)
  end

  teardown do
    FileUtils.rm_rf(@temp_dir)
    Cache.clear
  end

  def as(user, &block)
    CurrentUser.as(user, &block)
  end
end

class ActionDispatch::IntegrationTest
  extend ControllerHelper

  register_encoder :xml, response_parser: ->(body) { Nokogiri.XML(body) }
  register_encoder :atom, response_parser: ->(body) { Nokogiri.XML(body) }
  register_encoder :html, response_parser: ->(body) { Nokogiri.HTML5(body) }

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
end
