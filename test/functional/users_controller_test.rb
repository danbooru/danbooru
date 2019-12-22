require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  context "The users controller" do
    setup do
      @user = create(:user)
    end

    context "index action" do
      should "list all users" do
        get users_path
        assert_response :success
      end

      should "list all users for /users?name=<name>" do
        get users_path, params: { name: @user.name }
        assert_redirected_to(@user)
      end

      should "raise error for /users?name=<nonexistent>" do
        get users_path, params: { name: "nobody" }
        assert_response 404
      end

      should "list all users (with search)" do
        get users_path, params: {:search => {:name_matches => @user.name}}
        assert_response :success
      end

      should "list all users (with blank search parameters)" do
        get users_path, params: { search: { inviter: { name_matches: "" }, level: "", name: "test" } }
        assert_redirected_to users_path(search: { name: "test" })
      end
    end

    context "show action" do
      setup do
        # flesh out profile to get more test coverage of user presenter.
        @user = create(:banned_user, can_approve_posts: true, is_super_voter: true)
        as_user do
          create(:saved_search, user: @user)
          create(:post, uploader: @user, tag_string: "fav:#{@user.name}")
        end
      end

      should "render" do
        get user_path(@user)
        assert_response :success
      end

      should "show hidden attributes to the owner" do
        get_auth user_path(@user), @user, params: {format: :json}
        json = JSON.parse(response.body)

        assert_response :success
        assert_not_nil(json["last_logged_in_at"])
      end

      should "not show hidden attributes to others" do
        @another = create(:user)

        get_auth user_path(@another), @user, params: {format: :json}
        json = JSON.parse(response.body)

        assert_response :success
        assert_nil(json["last_logged_in_at"])
      end

      should "strip '?' from attributes" do
        get_auth user_path(@user), @user, params: {format: :xml}
        xml = Hash.from_xml(response.body)

        assert_response :success
        assert_equal(false, xml["user"]["can_upload"])
      end
    end

    context "profile action" do
      should "render the current user's profile" do
        get_auth profile_path, @user

        assert_response :success
        assert_select "#page h1", @user.name
      end

      should "render the current users's profile in json" do
        get_auth profile_path, @user, as: :json
        assert_response :success

        assert_equal(@user.comment_count, response.parsed_body["comment_count"])
      end

      should "redirect anonymous users to the sign in page" do
        get profile_path
        assert_redirected_to new_session_path
      end

      should "return 404 for anonymous api calls" do
        get profile_path(format: :json)
        assert_response 404
      end
    end

    context "new action" do
      setup do
        Danbooru.config.stubs(:enable_recaptcha?).returns(false)
      end

      should "render" do
        get new_user_path
        assert_response :success
      end
    end

    context "create action" do
      should "create a user" do
        assert_difference("User.count", 1) do
          post users_path, params: {:user => {:name => "xxx", :password => "xxxxx1", :password_confirmation => "xxxxx1"}}
        end
      end

      context "with sockpuppet validation enabled" do
        setup do
          Danbooru.config.unstub(:enable_sock_puppet_validation?)
          @user.update(last_ip_addr: "127.0.0.1")
        end

        should "not allow registering multiple accounts with the same IP" do
          assert_difference("User.count", 0) do
            post users_path, params: {:user => {:name => "dupe", :password => "xxxxx1", :password_confirmation => "xxxxx1"}}
          end
        end
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_user_path(@user), @user
        assert_response :success
      end
    end

    context "settings action" do
      should "render" do
        get_auth settings_path, @user

        assert_response :success
        assert_select "#page h1", "Settings"
      end

      should "redirect anonymous users to the sign in page" do
        get settings_path
        assert_redirected_to new_session_path
      end
    end

    context "update action" do
      should "update a user" do
        put_auth user_path(@user), @user, params: {:user => {:favorite_tags => "xyz"}}
        @user.reload
        assert_equal("xyz", @user.favorite_tags)
      end

      context "changing the level" do
        setup do
          @cuser = create(:user)
        end

        should "not work" do
          put_auth user_path(@user), @cuser, params: {:user => {:level => 40}}
          @user.reload
          assert_equal(20, @user.level)
        end
      end

      context "for a banned user" do
        should "allow the user to edit their settings" do
          @user = create(:banned_user)
          put_auth user_path(@user), @user, params: {:user => {:favorite_tags => "xyz"}}

          assert_equal("xyz", @user.reload.favorite_tags)
        end
      end
    end
  end
end
