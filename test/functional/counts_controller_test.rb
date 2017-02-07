require 'test_helper'

class CountsControllerTest < ActionController::TestCase
  context "The counts commentary controller" do
    context "posts action" do
      should "render" do
        get :posts
        assert_response :success
      end
    end
  end
end
