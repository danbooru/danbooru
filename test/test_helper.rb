ENV["RAILS_ENV"] = "test"

# Enable coverage only when COVERAGE is set or when running the whole test suite with `bin/rails test`, not when running individual test files.
if ENV["COVERAGE"].present? || ARGV.empty?
  require "simplecov"
  require "simplecov-cobertura"

  SimpleCov.start "rails" do
    add_group "Extractors", "app/logical/source"
    add_group "Libraries", ["app/logical", "lib"]
    add_group "Components", "app/components"
    add_group "Policies", "app/policies"
    add_group "Views", "app/views"

    enable_coverage :branch
    enable_coverage_for_eval

    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,      # tmp/coverage/index.html
      SimpleCov::Formatter::CoberturaFormatter, # tmp/coverage/coverage.xml (used by codecov in .github/workflows/test.yaml)
    ])

    coverage_dir "tmp/coverage"
  end
end

require_relative "../config/environment"
require "rails/test_help"

Rails.root.glob("test/factories/*.rb").each { |file| require file }
Rails.root.glob("test/test_helpers/*.rb").each { |file| require file }

Minitest::Reporters.use!([
  Minitest::Reporters::ProgressReporter.new,
  Minitest::Reporters::HtmlReporter.new(reports_dir: "tmp/html-test-results"),
  Minitest::Reporters::JUnitReporter.new("tmp/junit-test-results"),
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
  include IqdbTestHelper
  include UploadTestHelper
  include UrlTestHelper
  extend NormalizeAttributeHelper

  mock_post_version_service!
  mock_pool_version_service!

  unless Danbooru.config.debug_mode
    parallelize
    parallelize_setup do |worker|
      Rails.application.load_seed

      if defined?(SimpleCov)
        SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
      end
    end
  end

  parallelize_teardown do
    if defined?(SimpleCov)
      SimpleCov.result
    end
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
    return if user.nil? || user.is_anonymous?
    current_user_id = request&.session&.dig(:user_id)

    if current_user_id == user.id
      return
    elsif current_user_id.present? && current_user_id != user.id
      delete session_path # logout
    end

    post session_path, params: { session: { name: user.name, password: user.password }}

    if user.totp.present?
      post verify_totp_session_path, params: { totp: { user_id: user.signed_id(purpose: :verify_totp), code: user.totp.code }}
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

module Source::Tests; end

class ActiveSupport::ExtractorTestCase < ActiveSupport::TestCase
  include ExtractorTestHelper

  setup do
    skip "Skipping extractor tests as configured by the environment." if ENV["DANBOORU_SKIP_EXTRACTOR_TESTS"].to_s.truthy?
  end
end
