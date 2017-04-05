require 'test_helper'
require 'helpers/iqdb_test_helper'

class IqdbQueriesControllerTest < ActionController::TestCase
  include IqdbTestHelper

  context "The iqdb controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @posts = FactoryGirl.create_list(:post, 2)
      mock_iqdb_service!
    end

    context "create action" do
      should "render with a post_id" do
        mock_iqdb_matches!(@posts[0], @posts)
        post :create, { post_id: @posts[0].id, format: "js" }, { user_id: @user.id }

        assert_response :success
      end

      should "render with an url" do
        mock_iqdb_matches!(@posts[0].source, @posts)
        post :create, { url: @posts[0].source }, { user_id: @user.id }

        assert_response :success
      end

      should "render for a json response" do
        mock_iqdb_matches!(@posts[0].source, @posts)
        get :index, { url: @posts[0].source, format: "json" }, { user_id: @user.id }

        assert_response :success
      end
    end
  end
end
