require "application_system_test_case"

class ContentSecurityPolicyChromeTest < ChromeSystemTestCase
  context "The Content-Security-Policy" do
    setup do
      Danbooru.config.stubs(:storage_manager).returns(StorageManager::Local.new(base_url: "https://cdn.example.com/data", base_dir: @media_temp_dir))
      Danbooru.config.stubs(:reportbooru_server).returns("https://reportbooru.example.com")

      # Don't make real requests to external sites. Requests are intercepted after the browser checks the CSP.
      page.driver.with_playwright_page do |playwright_page|
        %w[https://*.example.com/** https://challenges.cloudflare.com/** https://fonts.googleapis.com/** https://fonts.gstatic.com/** https://static.cloudflareinsights.com/** https://cloudflareinsights.com/**].each do |url|
          playwright_page.context.route(url, ->(route, _request) { route.fulfill(status: 404, body: "") })
        end
      end

      record_csp_violations
    end

    should "allow resources from allowed sources and block everything else" do
      visit csp_test_path
      click_link "javascript: link"
      page.document.synchronize { evaluate_script("window.cspTest.done") or raise Capybara::ExpectationNotMet, "The CSP test page didn't finish" }

      expected_allowed = { "inlineScript" => true, "eval" => false, "newFunction" => false, "wasm" => true }
      assert_equal(expected_allowed, evaluate_script("window.cspTest.allowed"))

      # Alpine attributes still work without eval.
      assert_selector ".csp-test-alpine", text: "Alpine count: 1"
      find(".csp-test-alpine").click
      assert_selector ".csp-test-alpine", text: "Alpine count: 2"

      # Browsers only report the origin, not the full URL, for blocked iframes and objects.
      expected_violations = [
        "base-uri blocked https://blocked.example.com/",
        "connect-src blocked https://blocked.example.com/fetch",
        "connect-src blocked wss://blocked.example.com/websocket",
        "font-src blocked https://blocked.example.com/font.woff2",
        "form-action blocked https://challenges.cloudflare.com/csp-test-form",
        "frame-src blocked https://blocked.example.com",
        "img-src blocked https://blocked.example.com/image.png",
        "media-src blocked https://blocked.example.com/video.mp4",
        "object-src blocked https://blocked.example.com",
        "script-src blocked eval",
        "script-src blocked eval",
        "script-src-attr blocked inline",
        "script-src-elem blocked https://blocked.example.com/script.js",
        "script-src-elem blocked inline",
        "script-src-elem blocked inline",
        "style-src-elem blocked https://blocked.example.com/style.css",
        "worker-src blocked blob",
      ]

      # Violations are reported asynchronously, so wait for them before comparing.
      begin
        page.document.synchronize { evaluate_script("window.__cspViolations").sort == expected_violations or raise Capybara::ExpectationNotMet }
      rescue Capybara::ExpectationNotMet
        # Fall through to the assertion below to show the difference.
      end

      assert_equal(expected_violations, evaluate_script("window.__cspViolations").sort)
    end
  end
end
