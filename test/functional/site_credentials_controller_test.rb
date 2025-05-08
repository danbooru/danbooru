require 'test_helper'

class SiteCredentialsControllerTest < ActionDispatch::IntegrationTest
  context "The site credentials controller" do
    setup do
      @admin = create(:admin_user)
      @member = create(:member_user)
    end

    context "new action" do
      should "be viewable by admins" do
        get_auth new_site_credential_path, @admin
        assert_response :success
      end

      should "not be viewable by non-admins" do
        get_auth new_site_credential_path, @member
        assert_response 403
      end
    end

    context "create action" do
      should "create a new site credential" do
        post_auth site_credentials_path, @admin, params: { site_credential: { site: "Pixiv", credential: { phpsessid: "foo" }}}
        assert_response 302

        assert_equal("Pixiv", SiteCredential.last.site)
        assert_equal("foo", SiteCredential.last.credential["phpsessid"])
      end

      should "not allow invalid sites" do
        post_auth site_credentials_path, @admin, params: { site_credential: { site: "Foo" }}
        assert_response :success

        assert_equal(0, SiteCredential.count)
      end

      should "not allow unrecognized credential fields" do
        post_auth site_credentials_path, @admin, params: { site_credential: { site: "Pixiv", credential: { foo: "bar" }}}
        assert_response :success

        assert_equal(0, SiteCredential.count)
      end

      should "not allow missing credential fields" do
        post_auth site_credentials_path, @admin, params: { site_credential: { site: "Bluesky", credential: { identifier: "foo"}}}
        assert_response :success

        assert_equal(0, SiteCredential.count)
      end

      should "not allow non-admins to create credentials" do
        post_auth site_credentials_path, @member, params: { site_credential: { site: "Pixiv", credential: { phpsessid: "foo" }}}
        assert_response 403
      end
    end

    context "index action" do
      setup do
        @site_credential = create(:site_credential)
      end

      should "be viewable by admins" do
        get_auth site_credentials_path, @admin
        assert_response :success
      end

      should "not be viewable by non-admins" do
        get_auth site_credentials_path, @member
        assert_response 403
      end
    end
  end
end
