require 'test_helper'

class IqdbQueriesControllerTest < ActionDispatch::IntegrationTest
  context "The iqdb controller" do
    setup do
      @user = create(:user)
      as_user do
        @posts = FactoryBot.create_list(:post, 2)
      end
      mock_iqdb_service!
    end

    context "create action" do
      should "render with a post_id" do
        mock_iqdb_matches!(@posts[0], @posts)
        post_auth iqdb_queries_path, @user, params: { post_id: @posts[0].id, format: "js" }
        
        assert_response :success
      end

      should "render with an url" do
        mock_iqdb_matches!(@posts[0].source, @posts)
        post_auth iqdb_queries_path, @user, params: { url: @posts[0].source }

        assert_response :success
      end

      should "render for a json response" do
        mock_iqdb_matches!(@posts[0].source, @posts)
        get_auth iqdb_queries_path, @user, params: { url: @posts[0].source, format: "json" }

        assert_response :success
      end
    end
  end
end
