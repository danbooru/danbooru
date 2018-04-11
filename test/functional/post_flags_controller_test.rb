require 'test_helper'

class PostFlagsControllerTest < ActionDispatch::IntegrationTest
  context "The post flags controller" do
    setup do
      travel_to(2.weeks.ago) do
        @user = create(:user)
      end
    end

    context "new action" do
      should "render" do
        get_auth new_post_flag_path, @user
        assert_response :success
      end
    end

    context "index action" do
      setup do
        @user.as_current do
          @post = create(:post)
          @post_flag = create(:post_flag, :post => @post)
        end
      end

      should "render" do
        get_auth post_flags_path, @user
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_auth post_flags_path, @user, params: {:search => {:post_id => @post_flag.post_id}}
          assert_response :success
        end
      end
    end

    context "create action" do
      setup do
        @user.as_current do
          @post = create(:post)
        end
      end

      should "create a new flag" do
        assert_difference("PostFlag.count", 1) do
          assert_difference("PostFlag.count") do
            post_auth post_flags_path, @user, params: {:format => "js", :post_flag => {:post_id => @post.id, :reason => "xxx"}}
          end
        end
      end
    end
  end
end
