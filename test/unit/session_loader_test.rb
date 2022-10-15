require 'test_helper'

class SessionLoaderTest < ActiveSupport::TestCase
  context "SessionLoader" do
    setup do
      @request = mock
      @request.stubs(:host).returns("danbooru")
      @request.stubs(:remote_ip).returns("127.0.0.1")
      @request.stubs(:path).returns("/")
      @request.stubs(:authorization).returns(nil)
      @request.stubs(:cookie_jar).returns({})
      @request.stubs(:cookies).returns({})
      @request.stubs(:parameters).returns({})
      @request.stubs(:query_parameters).returns({})
      @request.stubs(:session).returns({})
      @request.stubs(:headers).returns({})
      SessionLoader.any_instance.stubs(:initialize_session_cookies)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.safe_mode = nil
    end

    context ".safe_mode?" do
      should "return true if the hostname is safebooru.donmai.us" do
        @request.stubs(:host).returns("safebooru.donmai.us")
        SessionLoader.new(@request).load

        assert_equal(true, CurrentUser.safe_mode?)
      end

      should "return false if the host contains the string danbooru" do
        @request.stubs(:host).returns("danbooru")
        SessionLoader.new(@request).load

        assert_equal(false, CurrentUser.safe_mode?)
      end

      should "return true if the user has enabled the safe mode account setting" do
        @user = create(:user, enable_safe_mode: true)
        @request.stubs(:session).returns(user_id: @user.id)
        SessionLoader.new(@request).load

        assert_equal(true, CurrentUser.safe_mode?)
      end
    end
  end
end
