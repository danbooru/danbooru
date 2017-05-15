require 'test_helper'

class PostReplacementsControllerTest < ActionController::TestCase
  context "The post replacements controller" do
    setup do
      @user = FactoryGirl.create(:user, can_approve_posts: true, created_at: 1.month.ago)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @post = FactoryGirl.create(:post)
      @post_replacement = FactoryGirl.create(:post_replacement, post_id: @post.id)
    end

    context "create action" do
      should "render" do
        params = {
          format: :json,
          post_id: @post.id,
          post_replacement: {
            replacement_url: "https://www.google.com/intl/en_ALL/images/logo.gif",
          }
        }

        assert_difference("@post.replacements.size") do
          post :create, params, { user_id: @user.id }
          @post.reload
        end

        assert_response :success
        assert_equal("https://www.google.com/intl/en_ALL/images/logo.gif", @post.source)
        assert_equal("e80d1c59a673f560785784fb1ac10959", @post.md5)
        assert_equal("e80d1c59a673f560785784fb1ac10959", Digest::MD5.file(@post.file_path).hexdigest)
      end
    end

    context "index action" do
      should "render" do
        get :index, {format: :json}
        assert_response :success
      end
    end
  end
end
