require 'test_helper'

class FavoriteGroupsControllerTest < ActionDispatch::IntegrationTest
  context "The favorite groups controller" do
    setup do
      @user = create(:user)
      @favgroup = create(:favorite_group, creator: @user)
    end

    context "index action" do
      setup do
        @mod_favgroup = create(:favorite_group, name: "monochrome", creator: build(:moderator_user, name: "fumimi"))
        @private_favgroup = create(:favorite_group, creator: @user, is_public: false)
      end

      should "render" do
        get favorite_groups_path
        assert_response :success
      end

      should respond_to_search({}).with { [@mod_favgroup, @favgroup] }
      should respond_to_search(name: "monochrome").with { @mod_favgroup }

      context "using includes" do
        should respond_to_search(creator_name: "fumimi").with { @mod_favgroup }
        should respond_to_search(creator: {level: User::Levels::MEMBER}).with { @favgroup }
      end

      context "for private favorite groups as the creator" do
        setup do
          CurrentUser.user = @user
        end

        should respond_to_search(is_public: "false").with { @private_favgroup }
      end
    end

    context "show action" do
      should "show public favgroups to anonymous users" do
        get favorite_group_path(@favgroup)
        assert_response :success
      end

      should "show private favgroups to the creator" do
        @favgroup.update!(is_public: false)
        get_auth favorite_group_path(@favgroup), @user
        assert_response :success
      end

      should "not show private favgroups to other users" do
        @favgroup = create(:favorite_group, is_public: false)
        get_auth favorite_group_path(@favgroup), create(:user)
        assert_response 403
      end
    end

    context "new action" do
      should "render" do
        get_auth new_favorite_group_path, @user
        assert_response :success
      end
    end

    context "create action" do
      should "render" do
        post_auth favorite_groups_path, @user, params: { favorite_group: FactoryBot.attributes_for(:favorite_group) }
        assert_redirected_to favorite_group_path(FavoriteGroup.last)
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_favorite_group_path(@favgroup), @user
        assert_response :success
      end
    end

    context "update action" do
      should "update posts" do
        @posts = create_list(:post, 2)
        put_auth favorite_group_path(@favgroup), @user, params: { favorite_group: { name: "foo", post_ids: @posts.map(&:id).join(" ") } }

        assert_redirected_to @favgroup
        assert_equal("foo", @favgroup.reload.name)
        assert_equal(@posts.map(&:id), @favgroup.post_ids)
      end

      should "not allow users to update favgroups belonging to other users" do
        put_auth favorite_group_path(@favgroup), create(:user), params: { favorite_group: { name: "foo" } }

        assert_response 403
        assert_not_equal("foo", @favgroup.reload.name)
      end
    end

    context "destroy action" do
      should "render" do
        delete_auth favorite_group_path(@favgroup), @user
        assert_redirected_to favorite_groups_path(search: { creator_name: @user.name })
      end

      should "not destroy favgroups belonging to other users" do
        delete_auth favorite_group_path(@favgroup), create(:user)
        assert_response 403
      end
    end

    context "add_post action" do
      should "render" do
        @post = create(:post)
        put_auth add_post_favorite_group_path(@favgroup), @user, params: {post_id: @post.id, format: "js"}
        assert_response :success
        assert_equal([@post.id], @favgroup.reload.post_ids)
      end

      should "not add posts to favgroups belonging to other users" do
        @post = create(:post)
        put_auth add_post_favorite_group_path(@favgroup), create(:user), params: {post_id: @post.id, format: "js"}
        assert_response 403
      end
    end

    context "edit order action" do
      should "render" do
        get_auth edit_favorite_group_order_path(@favgroup), @user
        assert_response :success
      end
    end
  end
end
