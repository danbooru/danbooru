require 'test_helper'

module Moderator
  class TagsControllerTest < ActionDispatch::IntegrationTest
    context "The tags controller" do
      setup do
        @user = create(:moderator_user)
        as_user do
          @post = create(:post)
        end
      end

      should "render the edit action" do
        get_auth edit_moderator_tag_path, @user
        assert_response :success
      end

      should "execute the update action" do
        put_auth moderator_tag_path, @user, params: {:tag => {:predicate => "aaa", :consequent => "bbb"}}
        assert_redirected_to edit_moderator_tag_path
      end

      should "fail gracefully if the update action fails" do
        put_auth moderator_tag_path, @user, params: {:tag => {:predicate => "", :consequent => "bbb"}}
        assert_redirected_to edit_moderator_tag_path
      end
    end
  end
end
