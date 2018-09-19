require 'test_helper'

class CountsControllerTest < ActionDispatch::IntegrationTest
  context "The counts commentary controller" do
    context "posts action" do
      should "render" do
        get posts_counts_path
        assert_response :success
      end

      should "render an error during a timeout" do
        Post.stubs(:fast_count).raises(Post::TimeoutError.new)
        get posts_counts_path
        assert_response :error
      end
    end
  end
end
