require "test_helper"

class FavoriteGroupsControllerTest < ActionDispatch::IntegrationTest
  context "The favorite groups controller" do
    setup do
      @user = create(:gold_user)
      @favgroup = create(:favorite_group, creator: @user)
      @private_favgroup = create(:private_favorite_group, creator: @user)
    end

    context "index action" do
      setup do
        @mod_favgroup = create(:favorite_group, name: "Beautiful Smile", creator: build(:moderator_user))
      end

      should "render" do
        get favorite_groups_path
        assert_response :success
      end

      should respond_to_search.with { [@mod_favgroup, @favgroup] }
      should respond_to_search(name_contains: "eautiful").with { @mod_favgroup }
      should respond_to_search(name_contains: "beautiful smile").with { @mod_favgroup }
      should respond_to_search(name_contains: "smiling beauty").with { [] }
      should respond_to_search(name_matches: "eautiful").with { [] }

      should "return 422 for post IDs that aren't integers" do
        get favorite_groups_path, params: { search: { post_ids_include_any_array: ["x"] }}, as: :json
        assert_response 422
        assert_equal("post_ids_include_any_array must be a list of integers", response.parsed_body["message"])
      end

      should "search post IDs by regex" do
        get favorite_groups_path(format: :json, search: { any_post_id_matches_regex: "x" })
        assert_response :success
        assert_equal([], response.parsed_body)
      end
      should respond_to_search(name_matches: "beautiful smile").with { @mod_favgroup }
      should respond_to_search(name_matches: "smiling beauty").with { @mod_favgroup }

      should respond_to_search(creator_name: -> { @mod_favgroup.creator.name }).with { @mod_favgroup }
      should respond_to_search(creator: { level: User::Levels::GOLD }).with { @favgroup }

      should respond_to_search(is_public: "false").as_user { @private_favgroup.creator }.with { @private_favgroup }
    end

    context "show action" do
      should "show public favgroups to anonymous users" do
        get favorite_group_path(@favgroup)
        assert_response :success
      end

      should "show private favgroups to the creator" do
        get_auth favorite_group_path(@private_favgroup), @user
        assert_response :success
      end

      should "show private favgroups to a superadmin" do
        get_auth favorite_group_path(@private_favgroup), create(:superadmin_user)
        assert_response :success
      end

      should "not show private favgroups to other users" do
        get_auth favorite_group_path(@private_favgroup), create(:user)
        assert_response 403
      end
    end

    context "new action" do
      should "render" do
        get_auth new_favorite_group_path, @user
        assert_response :success
      end

      should "not allow banned or restricted users" do
        get_auth new_favorite_group_path, create(:banned_user)
        assert_response 403

        get_auth new_favorite_group_path, create(:restricted_user)
        assert_response 403
      end
    end

    context "create action" do
      should "return an error for a missing name" do
        assert_no_difference("FavoriteGroup.count") do
          post_auth favorite_groups_path, @user, params: { favorite_group: { is_public: true }}, as: :json
        end

        assert_response 422
      end

      should "render" do
        post_auth favorite_groups_path, @user, params: { favorite_group: attributes_for(:favorite_group) }
        assert_redirected_to favorite_group_path(FavoriteGroup.last)
      end

      should "not allow banned or restricted users to create favgroups" do
        assert_no_difference("FavoriteGroup.count") do
          post_auth favorite_groups_path, create(:banned_user), params: { favorite_group: attributes_for(:favorite_group) }
          assert_response 403

          post_auth favorite_groups_path, create(:restricted_user), params: { favorite_group: attributes_for(:favorite_group) }
          assert_response 403
        end
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_favorite_group_path(@favgroup), @user
        assert_response :success
      end

      should "not allow banned or restricted users to edit their own favgroups" do
        banned_user = create(:banned_user)
        banned_favgroup = create(:favorite_group, creator: banned_user)
        get_auth edit_favorite_group_path(banned_favgroup), banned_user
        assert_response 403

        restricted_user = create(:restricted_user)
        restricted_favgroup = create(:favorite_group, creator: restricted_user)
        get_auth edit_favorite_group_path(restricted_favgroup), restricted_user
        assert_response 403
      end
    end

    context "update action" do
      should "update posts" do
        @posts = create_list(:post, 2)
        put_auth favorite_group_path(@favgroup), @user, params: { favorite_group: { name: "foo", post_ids: @posts.map(&:id).join(" ") }}

        assert_redirected_to @favgroup
        assert_equal("foo", @favgroup.reload.name)
        assert_equal(@posts.map(&:id), @favgroup.post_ids)
      end

      should "not allow users to update favgroups belonging to other users" do
        put_auth favorite_group_path(@favgroup), create(:user), params: { favorite_group: { name: "foo" }}

        assert_response 403
        assert_not_equal("foo", @favgroup.reload.name)
      end

      should "not allow banned or restricted users to update their own favgroups" do
        banned_user = create(:banned_user)
        banned_favgroup = create(:favorite_group, creator: banned_user)
        put_auth favorite_group_path(banned_favgroup), banned_user, params: { favorite_group: { name: "foo" }}
        assert_response 403
        assert_not_equal("foo", banned_favgroup.reload.name)

        restricted_user = create(:restricted_user)
        restricted_favgroup = create(:favorite_group, creator: restricted_user)
        put_auth favorite_group_path(restricted_favgroup), restricted_user, params: { favorite_group: { name: "foo" }}
        assert_response 403
        assert_not_equal("foo", restricted_favgroup.reload.name)
      end

      should "not allow non-Gold users to enable private favgroups" do
        @member = create(:user)
        @member_favgroup = create(:favorite_group, creator: @member)
        put_auth favorite_group_path(@member_favgroup), @member, params: { favorite_group: { is_private: true }}

        assert_response :success
        assert_equal(false, @member_favgroup.is_private?)
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

      should "not allow banned or restricted users to destroy their own favgroups" do
        banned_user = create(:banned_user)
        banned_favgroup = create(:favorite_group, creator: banned_user)
        delete_auth favorite_group_path(banned_favgroup), banned_user
        assert_response 403
        assert(FavoriteGroup.exists?(banned_favgroup.id))

        restricted_user = create(:restricted_user)
        restricted_favgroup = create(:favorite_group, creator: restricted_user)
        delete_auth favorite_group_path(restricted_favgroup), restricted_user
        assert_response 403
        assert(FavoriteGroup.exists?(restricted_favgroup.id))
      end
    end

    context "add_post action" do
      should "return 400 for a post_id param that isn't a string or integer" do
        put_auth add_post_favorite_group_path(@favgroup), @user, params: { post_id: [create(:post).id] }, as: :json
        assert_response 400

        put_auth remove_post_favorite_group_path(@favgroup), @user, params: { post_id: { a: 1 }}, as: :json
        assert_response 400
      end

      should "render" do
        @post = create(:post)
        put_auth add_post_favorite_group_path(@favgroup), @user, params: { post_id: @post.id, format: "js" }

        assert_response :success
        assert_equal([@post.id], @favgroup.reload.post_ids)
      end

      should "not add posts to favgroups belonging to other users" do
        @post = create(:post)
        put_auth add_post_favorite_group_path(@favgroup), create(:user), params: { post_id: @post.id, format: "js" }

        assert_response 403
        assert_equal([], @favgroup.reload.post_ids)
      end

      should "not allow banned or restricted users to add posts to their own favgroups" do
        @post = create(:post)

        banned_user = create(:banned_user)
        banned_favgroup = create(:favorite_group, creator: banned_user)
        put_auth add_post_favorite_group_path(banned_favgroup), banned_user, params: { post_id: @post.id, format: "js" }
        assert_response 403
        assert_equal([], banned_favgroup.reload.post_ids)

        restricted_user = create(:restricted_user)
        restricted_favgroup = create(:favorite_group, creator: restricted_user)
        put_auth add_post_favorite_group_path(restricted_favgroup), restricted_user, params: { post_id: @post.id, format: "js" }
        assert_response 403
        assert_equal([], restricted_favgroup.reload.post_ids)
      end
    end

    context "remove_post action" do
      should "render" do
        @post = create(:post)
        @favgroup.add(@post)
        assert_equal([@post.id], @favgroup.reload.post_ids)

        put_auth remove_post_favorite_group_path(@favgroup), @user, params: { post_id: @post.id, format: "js" }

        assert_response :success
        assert_equal([], @favgroup.reload.post_ids)
      end

      should "not remove posts from favgroups belonging to other users" do
        @post = create(:post)
        @favgroup.add(@post)
        assert_equal([@post.id], @favgroup.reload.post_ids)

        put_auth remove_post_favorite_group_path(@favgroup), create(:user), params: { post_id: @post.id, format: "js" }

        assert_response 403
        assert_equal([@post.id], @favgroup.reload.post_ids)
      end

      should "not allow banned or restricted users to remove posts from their own favgroups" do
        @post = create(:post)

        banned_user = create(:banned_user)
        banned_favgroup = create(:favorite_group, creator: banned_user, post_ids: [@post.id])
        put_auth remove_post_favorite_group_path(banned_favgroup), banned_user, params: { post_id: @post.id, format: "js" }
        assert_response 403
        assert_equal([@post.id], banned_favgroup.reload.post_ids)

        restricted_user = create(:restricted_user)
        restricted_favgroup = create(:favorite_group, creator: restricted_user, post_ids: [@post.id])
        put_auth remove_post_favorite_group_path(restricted_favgroup), restricted_user, params: { post_id: @post.id, format: "js" }
        assert_response 403
        assert_equal([@post.id], restricted_favgroup.reload.post_ids)
      end
    end

    context "edit order action" do
      should "render" do
        get_auth edit_favorite_group_order_path(@favgroup), @user
        assert_response :success
      end

      should "not allow banned or restricted users to edit order of their own favgroups" do
        banned_user = create(:banned_user)
        banned_favgroup = create(:favorite_group, creator: banned_user)
        get_auth edit_favorite_group_order_path(banned_favgroup), banned_user
        assert_response 403

        restricted_user = create(:restricted_user)
        restricted_favgroup = create(:favorite_group, creator: restricted_user)
        get_auth edit_favorite_group_order_path(restricted_favgroup), restricted_user
        assert_response 403
      end
    end
  end
end
