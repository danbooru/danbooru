require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  context "the sessions controller" do
    setup do
      @user = create(:user, password: "password", email_address_attributes: { address: "Foo.Bar+nospam@Googlemail.com" })
    end

    context "new action" do
      should "render" do
        get new_session_path
        assert_response :success
      end
    end

    context "create action" do
      should "log the user in when given the correct password" do
        post session_path, params: { session: { name: @user.name, password: "password" } }

        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
        assert_equal(true, @user.user_events.login.exists?)
      end

      should "log the user in when given their email address" do
        post session_path, params: { session: { name: "Foo.Bar+nospam@Googlemail.com", password: "password" } }

        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
        assert_equal(true, @user.user_events.login.exists?)
      end

      should "normalize the user's email address when logging in" do
        post session_path, params: { session: { name: "foobar@gmail.com", password: "password" } }

        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
        assert_equal(true, @user.user_events.login.exists?)
      end

      should "be case-insensitive towards the user's name when logging in" do
        post session_path, params: { session: { name: @user.name.upcase, password: "password" } }

        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
        assert_equal(true, @user.user_events.login.exists?)
      end

      should "not log the user in when given an incorrect username + password combination" do
        post session_path, params: { session: { name: @user.name, password: "wrong" } }

        assert_response 401
        assert_nil(nil, session[:user_id])
        assert_equal(true, @user.user_events.failed_login.exists?)
      end

      should "not log the user in when given an incorrect email" do
        post session_path, params: { session: { name: "foo@gmail.com", password: "password" } }

        assert_response 401
        assert_nil(nil, session[:user_id])
      end

      should "not log the user in when given an incorrect username" do
        post session_path, params: { session: { name: "dne", password: "password" } }

        assert_response 401
        assert_nil(nil, session[:user_id])
      end

      should "not allow approvers without 2FA to login from a proxy" do
        user = create(:approver_user, password: "password")
        ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("1.1.1.1")

        post session_path, params: { session: { name: user.name, password: "password" } }

        assert_response 401
        assert_nil(nil, session[:user_id])
      end

      should "not allow inactive accounts without 2FA to login from a proxy" do
        user = create(:user, password: "password", last_logged_in_at: 1.year.ago)
        ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("1.1.1.1")

        post session_path, params: { session: { name: user.name, password: "password" } }

        assert_response 401
        assert_nil(nil, session[:user_id])
      end

      should "allow approvers with 2FA enabled to login from a proxy" do
        user = create(:user_with_2fa, password: "password", level: User::Levels::APPROVER)
        ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("1.1.1.1")

        post session_path, params: { session: { name: user.name, password: "password" } }

        assert_response :success
        assert_nil(nil, session[:user_id])
        assert_equal(true, user.user_events.totp_login_pending_verification.exists?)
      end

      should "not log the user in yet if they have 2FA enabled" do
        user = create(:user_with_2fa, password: "password")

        post session_path, params: { session: { name: user.name, password: "password" } }

        assert_response :success
        assert_nil(nil, session[:user_id])
        assert_equal(true, user.user_events.totp_login_pending_verification.exists?)
      end

      should "not log the user in if the captcha is invalid" do
        # https://developers.cloudflare.com/turnstile/reference/testing/#dummy-sitekeys-and-secret-keys
        Danbooru.config.stubs(:captcha_site_key).returns("3x00000000000000000000FF") # forces an interactive challenge
        Danbooru.config.stubs(:captcha_secret_key).returns("2x0000000000000000000000000000000AA") # always fails

        post session_path, params: { session: { name: @user.name, password: "password" }, "cf-turnstile-response": "blah" }

        assert_response 401
        assert_nil(nil, session[:user_id])
        assert_equal(false, @user.user_events.failed_login.exists?)
      end

      should "log the user in user if the captcha is valid" do
        Danbooru.config.stubs(:captcha_site_key).returns("3x00000000000000000000FF") # forces an interactive challenge
        Danbooru.config.stubs(:captcha_secret_key).returns("1x0000000000000000000000000000000AA") # always passes

        post session_path, params: { session: { name: @user.name, password: "password", url: users_path }, "cf-turnstile-response": "blah" }

        assert_redirected_to users_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
        assert_equal("login", @user.user_events.last.category)
      end

      should "redirect the user when given an url param" do
        post session_path, params: { session: { name: @user.name, password: "password" }, url: tags_path }
        assert_redirected_to tags_path
      end

      should "not allow redirects to protocol-relative URLs" do
        post session_path, params: { session: { name: @user.name, password: "password" }, url: "//example.com" }
        assert_response 403
      end

      should "not allow deleted users to login" do
        @user.update!(is_deleted: true)
        post session_path, params: { session: { name: @user.name, password: "password" } }

        assert_response 401
        assert_nil(nil, session[:user_id])
        assert_equal(true, @user.user_events.failed_login.exists?)
      end

      should "not allow IP banned users to login" do
        @ip_ban = create(:ip_ban, category: :full, ip_addr: "1.2.3.4")
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.4" }

        assert_response 403
        assert_not_equal(@user.id, session[:user_id])
        assert_equal(1, @ip_ban.reload.hit_count)
        assert(@ip_ban.last_hit_at > 1.minute.ago)
      end

      should "allow partial IP banned users to login" do
        @ip_ban = create(:ip_ban, category: :partial, ip_addr: "1.2.3.4")
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.4" }

        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
        assert_equal(0, @ip_ban.reload.hit_count)
        assert_nil(@ip_ban.last_hit_at)
      end

      should "ignore deleted IP bans when logging in" do
        @ip_ban = create(:ip_ban, is_deleted: true, category: :full, ip_addr: "1.2.3.4")
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.4" }

        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
        assert_equal(0, @ip_ban.reload.hit_count)
        assert_nil(@ip_ban.last_hit_at)
      end

      should "rate limit logins to 1 per 10 minutes per IP" do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        freeze_time

        20.times do
          post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.4" }

          assert_redirected_to root_path
          assert_equal(@user.id, session[:user_id])

          reset! # clear session id
        end

        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.4" }
        assert_response 429
        assert_not_equal(@user.id, session[:user_id])

        travel 9.minutes
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.4" }
        assert_response 429
        assert_not_equal(@user.id, session[:user_id])

        travel 19.minutes
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.4" }
        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
      end

      should "rate limit logins to 1 per 10 minutes per IPv4 /24 subnet" do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        freeze_time

        20.times do |n|
          post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.#{n}" }

          assert_redirected_to root_path
          assert_equal(@user.id, session[:user_id])

          reset! # clear session id
        end

        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.21" }
        assert_response 429
        assert_not_equal(@user.id, session[:user_id])

        travel 9.minutes
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.22" }
        assert_response 429
        assert_not_equal(@user.id, session[:user_id])

        travel 19.minutes
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1.2.3.23" }
        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
      end

      should "rate limit logins to 1 per 10 minutes per IPv6 /64 subnet" do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        freeze_time

        20.times do |n|
          post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1:2:3:4:#{n}::1" }

          assert_redirected_to root_path
          assert_equal(@user.id, session[:user_id])

          reset! # clear session id
        end

        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1:2:3:4:21::1" }
        assert_response 429
        assert_not_equal(@user.id, session[:user_id])

        travel 9.minutes
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1:2:3:4:22::1" }
        assert_response 429
        assert_not_equal(@user.id, session[:user_id])

        travel 19.minutes
        post session_path, params: { session: { name: @user.name, password: "password" } }, headers: { REMOTE_ADDR: "1:2:3:4:23::1" }
        assert_redirected_to root_path
        assert_equal(@user.id, session[:user_id])
      end
    end

    context "verify_totp action" do
      should "log the user in if they enter the correct 2FA code" do
        @user = create(:user_with_2fa, password: "password")

        post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: @user.totp.code, url: users_path } }

        assert_redirected_to users_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
        assert_equal(true, @user.user_events.totp_login.exists?)
      end

      should "log the user in if they enter a 2FA code that was generated less than 30 seconds ago" do
        @user = create(:user_with_2fa, password: "password")
        code = travel_to(25.seconds.ago) { @user.totp.code }

        post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: code, url: users_path } }

        assert_redirected_to users_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
        assert_equal(true, @user.user_events.totp_login.exists?)
      end

      should "log the user in if they enter a 2FA code that was generated less than 30 seconds in the future" do
        @user = create(:user_with_2fa, password: "password")
        code = travel_to(25.seconds.from_now) { @user.totp.code }

        post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: code, url: users_path } }

        assert_redirected_to users_path
        assert_equal(@user.id, session[:user_id])
        assert_not_nil(@user.reload.last_ip_addr)
        assert_equal(true, @user.user_events.totp_login.exists?)
      end

      should "not log the user in if they enter an incorrect 2FA code" do
        @user = create(:user_with_2fa, password: "password")

        post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: "invalid", url: users_path } }

        assert_response :success
        assert_nil(nil, session[:user_id])
        assert_equal(true, @user.user_events.totp_failed_login.exists?)
      end

      should "not log the user in if they enter a 2FA code that was generated more than a minute ago" do
        @user = create(:user_with_2fa, password: "password")
        code = travel_to(65.seconds.ago) { @user.totp.code }

        post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: code, url: users_path } }

        assert_response :success
        assert_nil(nil, session[:user_id])
        assert_equal(true, @user.user_events.totp_failed_login.exists?)
      end

      should "not log the user in if they enter a 2FA code that was generated more than a minute in the future" do
        @user = create(:user_with_2fa, password: "password")
        code = travel_to(65.seconds.from_now) { @user.totp.code }

        post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: code, url: users_path } }

        assert_response :success
        assert_nil(nil, session[:user_id])
        assert_equal(true, @user.user_events.totp_failed_login.exists?)
      end

      context "when given a backup code" do
        should "log the user in if they enter a correct backup code" do
          @user = create(:user_with_2fa)
          backup_code = @user.backup_codes.first

          post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: backup_code, url: users_path } }

          assert_redirected_to users_path
          assert_equal(@user.id, session[:user_id])
          assert_equal(false, @user.reload.backup_codes.include?(backup_code))
          assert_equal("backup_code_login", @user.user_events.last.category)
        end

        should "not log the user in if they enter an incorrect backup code" do
          @user = create(:user_with_2fa)
          backup_code = "99999999"

          post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: backup_code, url: users_path } }

          assert_response :success
          assert_nil(nil, session[:user_id])
          assert_equal("totp_failed_login", @user.user_events.last.category)
        end

        should "not log the user in if they enter a used backup code" do
          @user = create(:user_with_2fa, backup_codes: [11111111, 22222222, 33333333])
          backup_code = 11111111

          post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: backup_code, url: users_path } }
          assert_redirected_to users_path
          assert_equal(@user.id, session[:user_id])

          delete_auth session_path, @user
          assert_nil(session[:user_id])

          post verify_totp_session_path, params: { totp: { user_id: @user.signed_id(purpose: :verify_totp), code: backup_code, url: users_path } }

          assert_response :success
          assert_nil(nil, session[:user_id])
          assert_equal("totp_failed_login", @user.user_events.last.category)
        end
      end
    end

    context "confirm_password action" do
      should "render for a logged in user" do
        get_auth confirm_password_session_path, @user
        assert_response :success
      end
    end

    context "reauthenticate action" do
      context "for a user with 2FA enabled" do
        setup do
          @user = create(:user_with_2fa, password: "password")
        end

        should "succeed if the user enters the right password and 2FA code" do
          travel_to(1.day.ago) { login_as(@user) }
          post reauthenticate_session_path, params: { session: { password: "password", verification_code: @user.totp.code, url: users_path } }

          assert_redirected_to users_path
          assert_equal(true, Time.zone.parse(session[:last_authenticated_at]) > 1.second.ago)
          assert_equal("totp_reauthenticate", @user.user_events.last.category)
        end

        should "succeed if the user enters the right password and backup code" do
          backup_code = @user.backup_codes.first

          travel_to(1.day.ago) { login_as(@user) }
          post reauthenticate_session_path, params: { session: { password: "password", verification_code: backup_code, url: users_path } }

          assert_redirected_to users_path
          assert_equal(true, Time.zone.parse(session[:last_authenticated_at]) > 1.second.ago)
          assert_equal(false, @user.reload.backup_codes.include?(backup_code))
          assert_equal("backup_code_reauthenticate", @user.user_events.last.category)
        end

        should "fail if the user enters the right password but the wrong 2FA code" do
          travel_to(1.day.ago) { login_as(@user) }
          post reauthenticate_session_path, params: { session: { password: "password", verification_code: "wrong", url: users_path } }

          assert_response :success
          assert_equal(true, Time.zone.parse(session[:last_authenticated_at]) < 1.second.ago)
          assert_equal("totp_failed_reauthenticate", @user.user_events.last.category)
        end

        should "fail if the user enters the wrong password and the right 2FA code" do
          travel_to(1.day.ago) { login_as(@user) }
          post reauthenticate_session_path, params: { session: { password: "wrong", verification_code: @user.totp.code, url: users_path } }

          assert_response :success
          assert_equal(true, Time.zone.parse(session[:last_authenticated_at]) < 1.second.ago)
          assert_equal("failed_reauthenticate", @user.user_events.last.category)
        end

        should "fail if the user enters the right password and the wrong backup code" do
          backup_code = "99999999"

          travel_to(1.day.ago) { login_as(@user) }
          post reauthenticate_session_path, params: { session: { password: "password", verification_code: backup_code, url: users_path } }

          assert_response :success
          assert_equal(true, Time.zone.parse(session[:last_authenticated_at]) < 1.second.ago)
          assert_equal("totp_failed_reauthenticate", @user.user_events.last.category)
        end

        should "fail if the user enters the wrong password and the right backup code" do
          backup_code = @user.backup_codes.first

          travel_to(1.day.ago) { login_as(@user) }
          post reauthenticate_session_path, params: { session: { password: "wrong", verification_code: backup_code, url: users_path } }

          assert_response :success
          assert_equal(true, Time.zone.parse(session[:last_authenticated_at]) < 1.second.ago)
          assert_equal("failed_reauthenticate", @user.user_events.last.category)
        end
      end

      context "for a user without 2FA enabled" do
        should "succeed if the user enters the right password" do
          travel_to(1.day.ago) { login_as(@user) }
          post reauthenticate_session_path, params: { session: { password: "password", url: users_path } }

          assert_redirected_to users_path
          assert_equal(true, Time.zone.parse(session[:last_authenticated_at]) > 1.second.ago)
          assert_equal("reauthenticate", @user.user_events.last.category)
        end

        should "fail if the user enters the wrong password" do
          travel_to(1.day.ago) { login_as(@user) }
          post reauthenticate_session_path, params: { session: { password: "wrong", url: users_path } }

          assert_response :success
          assert_equal(true, Time.zone.parse(session[:last_authenticated_at]) < 1.second.ago)
          assert_equal("failed_reauthenticate", @user.user_events.last.category)
        end
      end
    end

    context "destroy action" do
      should "log the user out" do
        delete_auth session_path, @user

        assert_redirected_to root_path
        assert_nil(session[:user_id])
        assert_equal("logout", @user.user_events.last.category)
      end

      should "not fail if the user is already logged out" do
        delete session_path

        assert_redirected_to root_path
        assert_nil(session[:user_id])
      end
    end

    context "logout action" do
      should "render" do
        get_auth logout_path, @user

        assert_response :success
        assert_equal(@user.id, session[:user_id])
        assert_equal(false, @user.user_events.logout.exists?)
      end
    end
  end
end
