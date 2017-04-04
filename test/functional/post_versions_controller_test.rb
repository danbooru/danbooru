require 'test_helper'
require 'helpers/post_archive_test_helper'

class PostVersionsControllerTest < ActionController::TestCase
  include PostArchiveTestHelper

  def setup
    super
    @user = FactoryGirl.create(:user)
    CurrentUser.user = @user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  def teardown
    super
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "The post versions controller" do
    context "index action" do
      setup do
        @post = FactoryGirl.create(:post)
        @post.update_attributes(:tag_string => "1 2", :source => "xxx")
        @post.update_attributes(:tag_string => "2 3", :rating => "e")
      end

      should "list all versions" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
        assert_not_nil(assigns(:post_versions))
      end

      should "list all versions that match the search criteria" do
        get :index, {:search => {:post_id => @post.id}}, {:user_id => @user.id}
        assert_response :success
        assert_not_nil(assigns(:post_versions))
      end
    end
  end
end
