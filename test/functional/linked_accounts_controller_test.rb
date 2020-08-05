require "test_helper"

class LinkedAccountsControllerTest < ActionDispatch::IntegrationTest
  context "The linked accounts controller" do
    setup do
      @user = create(:user)
    end

    context "new action" do
      should "work" do
        get_auth new_linked_account_path(site: "Discord", format: :js), @user, xhr: true
        assert_response :success

        get_auth new_linked_account_path(site: "DeviantArt", format: :js), @user, xhr: true
        assert_response :success
      end
    end

    context "index action" do
      context "for the global listing" do
        should "show only public accounts" do
          acc1 = create(:discord_account, is_public: true)
          acc2 = create(:discord_account, is_public: false)

          get linked_accounts_path
          assert_response :success
          assert_select "[data-id=#{acc1.id}]", true
          assert_select "[data-id=#{acc2.id}]", false
        end
      end

      context "for the user listing" do
        should "work for the user" do
          acc = create(:discord_account, is_public: true, user: @user)

          get_auth user_linked_accounts_path(@user), @user
          assert_response :success
        end

        should "not work for other users" do
          acc = create(:discord_account, is_public: true, user: @user)

          get user_linked_accounts_path(@user)
          assert_response 403
        end
      end
    end

    context "update action" do
      context "for the user" do
        should "work" do
          acc = create(:discord_account, is_public: true, user: @user)

          put_auth linked_account_path(acc, format: :js), @user, params: { linked_account: { is_public: false }}
          assert_response :success
          assert_equal(false, acc.reload.is_public)
        end
      end

      context "for another user" do
        should "not work" do
          acc = create(:discord_account, is_public: true)

          put_auth linked_account_path(acc, format: :js), @user, params: { linked_account: { is_public: false }}
          assert_response 403
          assert_equal(true, acc.reload.is_public)
        end
      end
    end

    context "destroy action" do
      context "for the user" do
        should "work" do
          acc = create(:discord_account, user: @user)

          delete_auth linked_account_path(acc, format: :js), @user
          assert_response :success
          assert_equal(0, LinkedAccount.count)
        end
      end

      context "for another user" do
        should "not work" do
          acc = create(:discord_account)

          delete_auth linked_account_path(acc, format: :js), @user
          assert_response 403
          assert_equal(1, LinkedAccount.count)
        end
      end
    end
  end
end
