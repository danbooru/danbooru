require 'test_helper'

class SourcesControllerTest < ActionController::TestCase
  context "The sources controller" do
    context "show action" do
      should "work for a pixiv URL" do
        get :show, { url: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=14901720", format: "json" }
        assert_response :success
      end

      should "work for a direct twitter URL with referer" do
        get :show, {
          url: "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large",
          ref: "https://twitter.com/nounproject/status/540944400767922176",
          format: "json"
        }

        assert_response :success
      end
    end
  end
end
