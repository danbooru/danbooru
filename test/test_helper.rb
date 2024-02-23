ENV["RAILS_ENV"] = "test"

require 'simplecov'
require_relative "../config/environment"
require 'rails/test_help'

Dir["#{Rails.root}/test/factories/*.rb"].sort.each { |file| require file }
Dir["#{Rails.root}/test/test_helpers/*.rb"].sort.each { |file| require file }

Minitest::Reporters.use!([
  Minitest::Reporters::ProgressReporter.new,
  Minitest::Reporters::HtmlReporter.new(reports_dir: "tmp/html-test-results"),
  Minitest::Reporters::JUnitReporter.new("tmp/junit-test-results")
])

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
  include AutotaggerHelper
  include DatabaseTestHelper
  include DownloadTestHelper
  include IqdbTestHelper
  include UploadTestHelper
  include SourceTestHelper
  extend StripeTestHelper
  extend NormalizeAttributeHelper

  mock_post_version_service!
  mock_pool_version_service!

  unless Danbooru.config.debug_mode
    parallelize
    parallelize_setup do |worker|
      Rails.application.load_seed

      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end
  end

  parallelize_teardown do |worker|
    SimpleCov.result
  end

  setup do
    Socket.stubs(:gethostname).returns("www.example.com")

    @temp_dir = Dir.mktmpdir("danbooru-uploads-")
    storage_manager = StorageManager::Local.new(base_url: "https://www.example.com/data", base_dir: @temp_dir)
    Danbooru.config.stubs(:storage_manager).returns(storage_manager)
    Danbooru.config.stubs(:backup_storage_manager).returns(StorageManager::Null.new)
    Danbooru.config.stubs(:rate_limits_enabled?).returns(false)
    Danbooru.config.stubs(:autotagger_url).returns(nil)
    Danbooru.config.stubs(:iqdb_url).returns(nil)
    Danbooru.config.stubs(:captcha_site_key).returns(nil)
    Danbooru.config.stubs(:captcha_site_key).returns(nil)

    at_exit { FileUtils.rm_rf(@temp_dir) }
  end

  teardown do
    FileUtils.rm_rf(@temp_dir)
    Cache.clear
  end

  def as(user, &block)
    CurrentUser.scoped(user, &block)
  end

  def assert_search_equals(expected_results, current_user: User.anonymous, **params)
    klass = subject.is_a?(ApplicationRecord) ? subject.class : subject
    results = klass.search(params, current_user)

    assert_equal(Array(expected_results).map(&:id), results.ids)
  end
end

class ActionDispatch::IntegrationTest
  extend ControllerHelper

  register_encoder :xml, response_parser: ->(body) { Nokogiri.XML(body) }
  register_encoder :atom, response_parser: ->(body) { Nokogiri.XML(body) }
  register_encoder :html, response_parser: ->(body) { Nokogiri.HTML5(body) }

  def login_as(user)
    post session_path, params: { session: { name: user.name, password: user.password } }

    if user.totp.present?
      post verify_totp_session_path, params: { totp: { user_id: user.signed_id(purpose: :verify_totp), code: user.totp.code } }
    end
  end

  def method_authenticated(method_name, url, user, **options)
    login_as(user)
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
