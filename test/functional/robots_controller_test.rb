require "test_helper"

class RobotsControllerTest < ActionDispatch::IntegrationTest
  context "index action" do
    should "work with web crawlers disabled" do
      Danbooru.config.stubs(:allow_web_crawlers?).returns(false)
      get robots_path(format: :text)
      assert_response :success
    end

    should "work with web crawlers enabled" do
      Danbooru.config.stubs(:allow_web_crawlers?).returns(true)
      get robots_path(format: :text)
      assert_response :success
    end

    should "not delete stale beta feature cookies, because the response is publicly cached" do
      cookies[:beta_feature_removed_feature] = "true"
      get robots_path(format: :text)

      assert_response :success
      assert_equal(true, response.cache_control[:public])
      assert_no_match(/beta_feature/, response.headers["Set-Cookie"].to_s)
    end
  end
end
