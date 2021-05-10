require 'test_helper'

class CountsControllerTest < ActionDispatch::IntegrationTest
  context "The counts commentary controller" do
    context "posts action" do
      should "render" do
        get posts_counts_path
        assert_response :success
      end

      should "render for json" do
        get posts_counts_path(format: :json)
        assert_response :success
      end

      should "render for xml" do
        get posts_counts_path(format: :xml)
        assert_response :success
      end
    end
  end
end
