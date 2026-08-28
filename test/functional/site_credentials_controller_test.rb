require "test_helper"

class SiteCredentialsControllerTest < ActionDispatch::IntegrationTest
  context "The site credentials controller" do
    setup do
      @admin = create(:admin_user)
      @member = create(:member_user)
    end

    context "new action" do
      should "be viewable by admins" do
        get_auth new_site_credential_path, @admin, reauthenticate: true
        assert_response :success
      end

      should "not be viewable by non-admins" do
        get_auth new_site_credential_path, @member, reauthenticate: true
        assert_response 403
      end
    end

    context "create action" do
      should "create a new site credential" do
        post_auth site_credentials_path, @admin, params: { site_credential: { site: "Pixiv", credential: { phpsessid: " foo " }}}, reauthenticate: true
        assert_response 302

        assert_equal("Pixiv", SiteCredential.last.site)
        assert_equal("foo", SiteCredential.last.credential["phpsessid"])

        assert_equal(SiteCredential.last, ModAction.last.subject)
        assert_equal("site_credential_create", ModAction.last.category)
        assert_match(/created a site credential for/, ModAction.last.description)
        assert_equal(@admin, ModAction.last.creator)
      end

      should "not allow invalid sites" do
        post_auth site_credentials_path, @admin, params: { site_credential: { site: "Foo" }}, reauthenticate: true
        assert_response :success

        assert_equal(0, SiteCredential.count)
      end

      should "not allow unrecognized credential fields" do
        post_auth site_credentials_path, @admin, params: { site_credential: { site: "Pixiv", credential: { foo: "bar" }}}, reauthenticate: true
        assert_response :success

        assert_equal(0, SiteCredential.count)
      end

      should "not allow missing credential fields" do
        post_auth site_credentials_path, @admin, params: { site_credential: { site: "Bluesky", credential: { identifier: "foo" }}}, reauthenticate: true
        assert_response :success

        assert_equal(0, SiteCredential.count)
      end

      should "not allow non-admins to create credentials" do
        post_auth site_credentials_path, @member, params: { site_credential: { site: "Pixiv", credential: { phpsessid: "foo" }}}, reauthenticate: true
        assert_response 403
      end
    end

    context "index action" do
      setup do
        @site_credential = create(:site_credential)
      end

      should "be viewable by admins" do
        get_auth site_credentials_path, @admin, reauthenticate: true
        assert_response :success
      end

      should "redirect to the confirm password page if the user hasn't recently authenticated" do
        login_as(@admin)
        travel_to 2.hours.from_now do
          get site_credentials_path
        end

        assert_redirected_to confirm_password_session_path(url: site_credentials_path)
      end

      should "not be viewable with an API key" do
        api_key = create(:api_key, user: @admin)
        get site_credentials_path(login: @admin.name, api_key: api_key.key), as: :json

        assert_redirected_to confirm_password_session_path(url: site_credentials_path(login: @admin.name, api_key: api_key.key))
      end

      should "not be viewable by non-admins" do
        get_auth site_credentials_path, @member, reauthenticate: true
        assert_response 403
      end

      should "not show personal credentials belonging to other admins" do
        @personal_credential = create(:site_credential, creator: create(:admin_user), is_public: false, credential: { phpsessid: "secret" })
        get_auth site_credentials_path, @admin, as: :json, reauthenticate: true

        assert_response :success
        assert_equal([@site_credential.id], response.parsed_body.pluck("id"))
      end
    end

    context "show action" do
      should "be viewable by admins" do
        @site_credential = create(:site_credential)
        get_auth site_credential_path(@site_credential), @admin, reauthenticate: true

        assert_redirected_to site_credentials_path(search: { id: @site_credential.id })
      end

      should "redirect to the confirm password page if the user hasn't recently authenticated" do
        @site_credential = create(:site_credential)
        login_as(@admin)
        travel_to 2.hours.from_now do
          get site_credential_path(@site_credential, format: :json)
        end

        assert_redirected_to confirm_password_session_path(url: site_credential_path(@site_credential, format: :json))
      end

      should "not be viewable by non-admins" do
        @site_credential = create(:site_credential)
        get_auth site_credential_path(@site_credential), @member, reauthenticate: true

        assert_response 403
      end
    end

    context "update action" do
      should "allow admins to disable credentials" do
        @site_credential = create(:site_credential)
        put_auth site_credential_path(@site_credential), @admin, params: { site_credential: { is_enabled: false }}, reauthenticate: true

        assert_redirected_to site_credentials_path
        assert_equal(false, @site_credential.reload.is_enabled?)

        assert_equal(@site_credential, ModAction.last.subject)
        assert_equal("site_credential_disable", ModAction.last.category)
        assert_match(/disabled a site credential for/, ModAction.last.description)
        assert_equal(@admin, ModAction.last.creator)
      end

      should "allow admins to enable credentials" do
        @site_credential = create(:site_credential, is_enabled: false)
        put_auth site_credential_path(@site_credential), @admin, params: { site_credential: { is_enabled: true }}, reauthenticate: true

        assert_redirected_to site_credentials_path
        assert_equal(true, @site_credential.reload.is_enabled?)

        assert_equal(@site_credential, ModAction.last.subject)
        assert_equal("site_credential_enable", ModAction.last.category)
        assert_match(/enabled a site credential for/, ModAction.last.description)
        assert_equal(@admin, ModAction.last.creator)
      end

      should "not allow admins to modify credentials" do
        @site_credential = create(:site_credential, credential: { phpsessid: "old" })
        put_auth site_credential_path(@site_credential), @admin, params: { site_credential: { credential: { phpsessid: "new" }}}, reauthenticate: true

        assert_response 403
        assert_equal({ phpsessid: "old" }, @site_credential.reload.credential.symbolize_keys)
      end

      should "not allow non-admins to update credentials" do
        @site_credential = create(:site_credential)
        put_auth site_credential_path(@site_credential), @member, params: { site_credential: { is_enabled: false }}, reauthenticate: true

        assert_response 403
        assert_equal(true, @site_credential.reload.is_enabled?)
      end
    end

    context "destroy action" do
      should "allow a superadmin to delete credentials" do
        @user = create(:superadmin_user)
        @site_credential = create(:site_credential)
        assert_equal(true, ModAction.exists?(category: "site_credential_create"))

        delete_auth site_credential_path(@site_credential), @user, reauthenticate: true

        assert_redirected_to site_credentials_path
        assert_equal(0, SiteCredential.count)

        assert_nil(ModAction.last.subject)
        assert_equal("site_credential_delete", ModAction.last.category)
        assert_match(/deleted a site credential for/, ModAction.last.description)
        assert_equal(@user, ModAction.last.creator)
        assert_equal(false, ModAction.exists?(category: "site_credential_create"))
      end

      should "not allow non-owners to delete credentials" do
        @site_credential = create(:site_credential)
        delete_auth site_credential_path(@site_credential), @admin, reauthenticate: true

        assert_response 403
        assert_equal(1, SiteCredential.count)
      end
    end
  end
end
