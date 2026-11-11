require "test_helper"

class SourcesControllerTest < ActionDispatch::IntegrationTest
  context "The sources controller" do
    setup do
      @user = create(:user)
    end

    context "show action" do
      should "not allow anonymous users" do
        get source_path, params: { url: "https://twitter.com/ttguweiz/status/1794358058526892509" }
        assert_response 403
      end

      should "not allow anonymous users with the API" do
        get source_path(format: :json), params: { url: "https://twitter.com/ttguweiz/status/1794358058526892509" }
        assert_response 403
      end

      should "work for a pixiv URL" do
        get_auth source_path, @user, params: { url: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=14901720", format: "json" }
        assert_response :success
      end

      should "work for a direct twitter URL with referer" do
        get_auth source_path, @user, params: {
          url: "https://pbs.twimg.com/media/B4HSEP5CUAA4xyu.png:large",
          ref: "https://twitter.com/nounproject/status/540944400767922176",
          format: "json",
        }

        assert_response :success
      end

      should "work for a HTML response without a URL" do
        get_auth source_path, @user

        assert_response :success
      end

      should "work for a HTML response with a URL" do
        get_auth source_path, @user, params: { url: "https://twitter.com/ttguweiz/status/1794358058526892509" }

        assert_response :success
      end

      should "work for a HTML response with mode=json" do
        get_auth source_path, @user, params: { url: "https://twitter.com/ttguweiz/status/1794358058526892509", mode: "json" }

        assert_response :success
      end

      should "work for a HTML response with mode=test" do
        get_auth source_path, @user, params: { url: "https://twitter.com/ttguweiz/status/1794358058526892509", mode: "test" }

        assert_response :success
      end
    end
  end
end
