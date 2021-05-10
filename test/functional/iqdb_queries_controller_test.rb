require 'test_helper'

class IqdbQueriesControllerTest < ActionDispatch::IntegrationTest
  context "The iqdb controller" do
    setup do
      @user = create(:user)
      @post = as(@user) { create(:post) }
    end

    context "show action" do
      context "with a url parameter" do
        should "render a response" do
          @url = "https://google.com"
          @matches = [{ "post_id" => @post.id, "width" => 128, "height" => 128, "score" => 95.0 }]
          mock_iqdb_matches(@matches)

          get_auth iqdb_queries_path, @user, as: :javascript, params: { url: @url }

          assert_response :success
          assert_select("#post_#{@post.id}")
        end
      end

      context "with a post_id parameter" do
        should "redirect to iqdbs" do
          @matches = [{ "post_id" => @post.id, "width" => 128, "height" => 128, "score" => 95.0 }]
          mock_iqdb_matches(@matches)

          get_auth iqdb_queries_path, @user, params: { post_id: @post.id }

          assert_response :success
          assert_select("#post_#{@post.id}")
        end
      end
    end
  end
end
