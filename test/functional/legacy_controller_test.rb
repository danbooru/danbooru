require 'test_helper'

class LegacyControllerTest < ActionDispatch::IntegrationTest
  context "The legacy controller" do
    context "post action" do
      should "work" do
        get "/post/index.xml"
        assert_response :success

        get "/post/index.json"
        assert_response :success
      end
    end

    context "tag action" do
      should "work" do
        get "/tag/index.xml"
        assert_response :success

        get "/tag/index.json"
        assert_response :success
      end
    end
  end
end
