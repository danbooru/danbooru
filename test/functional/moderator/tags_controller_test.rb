require 'test_helper'

module Moderator
  class TagsControllerTest < ActionController::TestCase
    context "The tags controller" do
      setup do
        @user = FactoryGirl.create(:moderator_user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        @post = FactoryGirl.create(:post)
      end
      
      should "render the edit action" do
        get :edit, {}, {:user_id => @user.id}
        assert_response :success
      end

      should "execute the update action" do
        post :update, {:tag => {:predicate => "aaa", :consequent => "bbb"}}, {:user_id => @user.id}
        assert_redirected_to edit_moderator_tag_path
      end
      
      should "fail gracefully if the update action fails" do
        post :update, {:tag => {:predicate => "", :consequent => "bbb"}}, {:user_id => @user.id}
        assert_redirected_to edit_moderator_tag_path
      end
    end
  end
end
