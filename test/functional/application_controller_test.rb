require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  context "The application controller" do
    should "return 406 Not Acceptable for a bad file extension" do
      get posts_path, params: { format: :jpg }
      assert_response 406

      get posts_path, params: { format: :blah }
      assert_response 406
    end

    context "on a RecordNotFound error" do
      should "return 404 Not Found even with a bad file extension" do
        get post_path("bad.json")
        assert_response 404

        get post_path("bad.jpg")
        assert_response 404

        get post_path("bad.blah")
        assert_response 404
      end
    end

    context "on a PaginationError" do
      should "return 410 Gone even with a bad file extension" do
        get posts_path, params: { page: 999999999 }, as: :json
        assert_response 410

        get posts_path, params: { page: 999999999 }, as: :jpg
        assert_response 410

        get posts_path, params: { page: 999999999 }, as: :blah
        assert_response 410
      end
    end

    context "on api authentication" do
      setup do
        @user = create(:user, password: "password")
        @api_key = ApiKey.generate!(@user)
      end

      context "using http basic auth" do
        should "succeed for api key matches" do
          basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key.key}")}"
          get edit_user_path(@user), headers: { HTTP_AUTHORIZATION: basic_auth_string }
          assert_response :success
        end

        should "fail for api key mismatches" do
          basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:badpassword")}"
          get edit_user_path(@user), headers: { HTTP_AUTHORIZATION: basic_auth_string }
          assert_response 401
        end
      end

      context "using the api_key parameter" do
        should "succeed for api key matches" do
          get edit_user_path(@user), params: { login: @user.name, api_key: @api_key.key }
          assert_response :success
        end

        should "fail for api key mismatches" do
          get edit_user_path(@user), params: { login: @user.name }
          assert_response 401

          get edit_user_path(@user), params: { api_key: @api_key.key }
          assert_response 401

          get edit_user_path(@user), params: { login: @user.name, api_key: "bad" }
          assert_response 401
        end
      end

      context "using the password_hash parameter" do
        should "succeed for password matches" do
          get edit_user_path(@user), params: { login: @user.name, password_hash: User.sha1("password") }
          assert_response :success
        end

        should "fail for password mismatches" do
          get edit_user_path(@user), params: { login: @user.name }
          assert_response 401

          get edit_user_path(@user), params: { password_hash: User.sha1("password") }
          assert_response 401

          get edit_user_path(@user), params: { login: @user.name, password_hash: "bad" }
          assert_response 401
        end
      end

      context "without any authentication" do
        should "redirect to the login page" do
          get edit_user_path(@user)
          assert_redirected_to new_session_path(url: edit_user_path(@user))
        end
      end
    end

    context "on session cookie authentication" do
      should "succeed" do
        user = create(:user, password: "password")

        post session_path, params: { name: user.name, password: "password" }
        get edit_user_path(user)

        assert_response :success
      end
    end

    context "when the api limit is exceeded" do
      should "fail with a 429 error" do
        user = create(:user)
        post = create(:post, rating: "s")
        TokenBucket.any_instance.stubs(:throttled?).returns(true)

        put_auth post_path(post), user, params: { post: { rating: "e" } }

        assert_response 429
        assert_equal("s", post.reload.rating)
      end
    end
  end
end
