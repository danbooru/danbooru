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
          @url = "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"
          @matches = [{ post_id: @post.id, score: 95.0 }]
          mock_iqdb_matches(@matches)

          get_auth iqdb_queries_path, @user, as: :javascript, params: { url: @url }

          assert_response :success
          assert_select("#post_#{@post.id}")
        end

        should "return an error if the url doesn't have any images" do
          mock_iqdb_matches([])
          get_auth iqdb_queries_path, @user, params: { url: "https://twitter.com/dril/status/384408932061417472" }

          assert_response :success
          assert_select ".post-gallery", /No posts found/
          assert_select "#notice", /Search failed: .* has no images/
        end
      end

      context "with a post_id parameter" do
        should "render a response" do
          @matches = [{ post_id: @post.id, score: 95.0 }]
          mock_iqdb_matches(@matches)

          # Make the call to `@post.file(:preview)` work.
          Post.any_instance.stubs(:file).returns(File.open("test/files/test.jpg"))

          get_auth iqdb_queries_path, @user, params: { post_id: @post.id }

          assert_response :success
          assert_select("#post_#{@post.id}")
        end
      end

      context "with a file parameter" do
        should "render a response" do
          @matches = [{ post_id: @post.id, score: 95.0 }]
          mock_iqdb_matches(@matches)

          file = Rack::Test::UploadedFile.new("test/files/test.jpg")
          post_auth iqdb_queries_path(format: :json), @user, params: { search: { file: file }}

          assert_response :success
          assert_equal([{ post_id: @post.id, score: 95.0, post: as(@user) { @post.as_json } }.with_indifferent_access], response.parsed_body)
        end
      end
    end
  end
end
