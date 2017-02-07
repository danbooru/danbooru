require 'test_helper'

class SourcesControllerTest < ActionController::TestCase
  context "The sources controller" do
    context "show action" do
      should "work" do
        get :show, { url: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=14901720", format: "json" }
        assert_response :success
      end
    end
  end
end
