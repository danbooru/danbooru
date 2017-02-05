require 'test_helper'

class FavoriteGroupsControllerTest < ActionController::TestCase
  context "The favorite groups controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    context "index action" do
      should "render" do
        get :index
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        favgroup = FactoryGirl.create(:favorite_group)

        get :show, { id: favgroup.id }
        assert_response :success
      end
    end

    context "new action" do
      should "render" do
        get :new, {}, { user_id: @user.id }
        assert_response :success
      end
    end

    context "create action" do
      should "render" do
        post :create, { favorite_group: FactoryGirl.attributes_for(:favorite_group) }, { user_id: @user.id }
        assert_redirected_to favorite_groups_path
      end
    end

    context "edit action" do
      should "render" do
        favgroup = FactoryGirl.create(:favorite_group, creator: @user)

        get :edit, { id: favgroup.id }, { user_id: @user.id }
        assert_response :success
      end
    end

    context "update action" do
      should "render" do
        favgroup = FactoryGirl.create(:favorite_group, creator: @user)
        params = { id: favgroup.id, favorite_group: { name: "foo" } }

        put :update, params, { user_id: @user.id }
        assert_redirected_to favgroup
        assert_equal("foo", favgroup.reload.name)
      end
    end

    context "destroy action" do
      should "render" do
        favgroup = FactoryGirl.create(:favorite_group, creator: @user)

        delete :destroy, { id: favgroup.id }, { user_id: @user.id }
        assert_redirected_to favorite_groups_path
      end
    end

    context "add_post action" do
      should "render" do
        favgroup = FactoryGirl.create(:favorite_group, creator: @user)
        post = FactoryGirl.create(:post)

        put :add_post, { id: favgroup.id, post_id: post.id, format: "js" }, { user_id: @user.id }
        assert_response :success
        assert_equal([post.id], favgroup.reload.post_id_array)
      end
    end
  end
end
