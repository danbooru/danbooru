require "test_helper"
require "socket"

Capybara.server = :puma, { silence_fork_callback_warning: true, Threads: "0:1" }
Capybara.server_host = "0.0.0.0"
Capybara.app_host = "http://#{Socket.ip_address_list.find { |address| address.ipv4? && !address.ipv4_loopback? }.ip_address}"
Capybara.always_include_port = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemTestHelper

  self.lock_threads = false

  class_attribute :browser_name

  PLAYWRIGHT_SERVER_URL = "ws://playwright:3000/"

  def self.playwright_server_up?
    uri = URI(PLAYWRIGHT_SERVER_URL)
    TCPSocket.new(uri.host, uri.port).close
    true
  rescue StandardError
    false
  end

  # The playwright container is optional (`bin/dev --profile test up`), so skip instead of hard-crashing when it isn't running.
  def self.driven_by_remote_browser(browser_type)
    setup do
      skip "#{PLAYWRIGHT_SERVER_URL} is not reachable - is the `playwright` container running? (bin/dev --profile test up)" unless ApplicationSystemTestCase.playwright_server_up?
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
