require "application_system_test_case"

class ReportbooruChromeTest < ChromeSystemTestCase
  context "Reportbooru" do
    setup do
      Danbooru.config.stubs(:reportbooru_server).returns("https://reportbooru.example.com")
      Danbooru.config.stubs(:reportbooru_key).returns("secret")

      @verifier = ActiveSupport::MessageVerifier.new("secret", serializer: JSON, digest: "SHA256")
      @requests = Queue.new
      page.driver.with_playwright_page do |playwright_page|
        playwright_page.context.route("https://reportbooru.example.com/**", lambda do |route, request|
          @requests << [request.method, request.url, Rack::Utils.parse_query(request.post_data)]
          route.fulfill(status: 200, body: "")
        end)
      end

      record_csp_violations
    end

    should "record post views" do
      post = create(:post)
      visit post_path(post)

      method, url, params = @requests.pop(timeout: 5)
      assert_equal(["POST", "https://reportbooru.example.com/post_views"], [method, url])
      assert_match(/\A#{post.id},/, @verifier.verify(params["msg"]))
      assert_no_csp_violations
    end

    should "record post searches" do
      create(:post, tag_string: "touhou")
      visit posts_path(tags: "touhou")

      method, url, params = @requests.pop(timeout: 5)
      assert_equal(["POST", "https://reportbooru.example.com/post_searches"], [method, url])
      assert_match(/\Aps-touhou,/, @verifier.verify(params["sig"]))
      assert_no_csp_violations
    end

    should "record missed searches" do
      visit posts_path(tags: "does_not_exist")

      method, url, params = @requests.pop(timeout: 5)
      assert_equal(["POST", "https://reportbooru.example.com/missed_searches"], [method, url])
      assert_match(/\Adoes_not_exist,/, @verifier.verify(params["sig"]))
      assert_no_csp_violations
    end
  end
end
