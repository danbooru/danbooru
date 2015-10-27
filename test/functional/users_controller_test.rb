require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  context "The users controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
    end

    context "index action" do
      setup do
        FactoryGirl.create(:user, :name => "abc")
      end

      should "list all users" do
        get :index
        assert_response :success
      end

      should "list all users (with search)" do
        get :index, {:search => {:name_matches => "abc"}}
        assert_response :success
      end
    end

    context "show action" do
      setup do
        @user = FactoryGirl.create(:user)
      end

      should "render" do
        get :show, {:id => @user.id}
        assert_response :success
      end
    end

    context "create action" do
      should "create a user" do
        assert_difference("User.count", 1) do
          post :create, {:user => {:name => "xxx", :password => "xxxxx1", :password_confirmation => "xxxxx1"}}, {:user_id => @user.id}
          assert_not_nil(assigns(:user))
          assert_equal([], assigns(:user).errors.full_messages)
        end
      end
    end

    context "edit action" do
      setup do
        @user = FactoryGirl.create(:user)
      end

      should "render" do
        get :edit, {:id => @user.id}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "update action" do
      setup do
        @user = FactoryGirl.create(:user)
      end

      should "update a user" do
        post :update, {:id => @user.id, :user => {:favorite_tags => "xyz"}}, {:user_id => @user.id}
        @user.reload
        assert_equal("xyz", @user.favorite_tags)
      end

      context "changing the level" do
        setup do
          @cuser = FactoryGirl.create(:user)
        end

        should "not work" do
          post :update, {:id => @user.id, :user => {:level => 40}}, {:user_id => @cuser.id}
          @user.reload
          assert_equal(20, @user.level)
        end
      end
    end
  end
end
