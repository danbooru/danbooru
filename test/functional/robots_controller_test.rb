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
  end
end
