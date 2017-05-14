require 'test_helper'

class PostReplacementsControllerTest < ActionController::TestCase
  context "The post replacements controller" do
    setup do
      @user = FactoryGirl.create(:user, can_approve_posts: true)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @post = FactoryGirl.create(:post)
      @post_replacement = FactoryGirl.create(:post_replacement, post_id: @post.id)
    end

    context "index action" do
      should "render" do
        get :index, {format: :json}
        assert_response :success
      end
    end
  end
end
