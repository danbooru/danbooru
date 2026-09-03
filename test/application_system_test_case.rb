require "test_helper"
require "socket"
require "drb/unix"

Capybara.configure do |config|
  config.server = :puma, {
    Silent: true,
    silence_fork_callback_warning: true,
    Threads: "0:1",
    workers: 0,
  }
  config.server_host = "0.0.0.0"
  config.app_host = "http://#{Socket.ip_address_list.find { |address| address.ipv4? && !address.ipv4_loopback? }.ip_address}"
  config.always_include_port = true
  config.default_max_wait_time = 5
end

module IgnoreMissingDrbUnixSocket
  def close
    super
  rescue Errno::ENOENT
    # Another process/thread already removed the Unix socket.
  end
end

DRb::DRbUNIXSocket.prepend(IgnoreMissingDrbUnixSocket)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemTestHelper

  class_attribute :browser_name

  PLAYWRIGHT_SERVER_URL = "ws://playwright:3000/"

  # Make Rails serve files to the playwright container
  setup do
    data_dir = Rails.public_path.join("data").tap { |dir| FileUtils.mkdir_p(dir) }
    @media_temp_dir = Dir.mktmpdir("danbooru-uploads-", data_dir)
    base_url = "#{Capybara.app_host}:#{Capybara.current_session.server.port}/data/#{File.basename(@media_temp_dir)}"
    Danbooru.config.stubs(:storage_manager).returns(StorageManager::Local.new(base_url: base_url, base_dir: @media_temp_dir))
  end

  teardown do
    FileUtils.rm_rf(@media_temp_dir)
  end

  def self.playwright_server_up?
    uri = URI(PLAYWRIGHT_SERVER_URL)
    TCPSocket.new(uri.host, uri.port).close
    true
  rescue StandardError
    false
  end

  # The playwright container is optional (`bin/dev --profile test up playwright`),
  # so skip instead of hard-crashing when it isn't running.
  def self.driven_by_remote_browser(browser_type)
    setup do
      skip "The playwright server (#{PLAYWRIGHT_SERVER_URL}) is not reachable - run `bin/dev --profile test up playwright -d`" unless ApplicationSystemTestCase.playwright_server_up?
    end

    driver_name = :"playwright_#{browser_type}"

    Capybara.register_driver(driver_name) do |app|
      Capybara::Playwright::Driver.new(
        app,
        browser_type: browser_type,
        browser_server_endpoint_url: PLAYWRIGHT_SERVER_URL,
        headless: true,
        viewport: { width: 1920, height: 1080 },
      )
    end

    driven_by driver_name
    self.browser_name = browser_type.to_s.capitalize
  end
end

class ChromeSystemTestCase < ApplicationSystemTestCase
  driven_by_remote_browser :chromium
end

class FirefoxSystemTestCase < ApplicationSystemTestCase
  driven_by_remote_browser :firefox
end

class WebkitSystemTestCase < ApplicationSystemTestCase
  driven_by_remote_browser :webkit
end
