require 'test_helper'

class DmailsControllerTest < ActionDispatch::IntegrationTest
  context "The dmails controller" do
    setup do
      @user = create(:user)
      @unrelated_user = create(:user)
      as_user do
        @dmail = create(:dmail, :owner => @user)
      end
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "new action" do
      should "get the page" do
        get_auth new_dmail_path, @user
        assert_response :success
      end

      context "with a respond_to_id" do
        should "check privileges" do
          @user2 = create(:user)
          get_auth new_dmail_path, @user2, params: {:respond_to_id => @dmail.id}
          assert_response 403
        end

        should "prefill the fields" do
          get_auth new_dmail_path, @user, params: {:respond_to_id => @dmail.id}
          assert_response :success
        end

        context "and a forward flag" do
          should "not populate the to field" do
            get_auth new_dmail_path, @user, params: {:respond_to_id => @dmail.id, :forward => true}
            assert_response :success
          end
        end
      end
    end

    context "index action" do
      should "show dmails owned by the current user by sent" do
        get_auth dmails_path, @user, params: {:search => {:owner_id => @dmail.owner_id, :folder => "sent"}}
        assert_response :success
      end

      should "show dmails owned by the current user by received" do
        get_auth dmails_path, @user, params: {:search => {:owner_id => @dmail.owner_id, :folder => "received"}}
        assert_response :success
      end

      should "not show dmails not owned by the current user" do
        get_auth dmails_path, @user, params: {:search => {:owner_id => @dmail.owner_id}}
        assert_response :success
      end

      should "work for banned users" do
        as(create(:admin_user)) do
          create(:ban, :user => @user)
        end
        get_auth dmails_path, @dmail.owner, params: {:search => {:owner_id => @dmail.owner_id, :folder => "sent"}}

        assert_response :success
      end
    end

    context "show action" do
      should "show dmails owned by the current user" do
        get_auth dmail_path(@dmail), @dmail.owner
        assert_response :success
      end

      should "not show dmails not owned by the current user" do
        get_auth dmail_path(@dmail), @unrelated_user
        assert_response(403)
      end
    end

    context "create action" do
      setup do
        @user_2 = create(:user)
      end

      should "create two messages, one for the sender and one for the recipient" do
        assert_difference("Dmail.count", 2) do
          dmail_attribs = {:to_id => @user_2.id, :title => "abc", :body => "abc"}
          post_auth dmails_path, @user, params: {:dmail => dmail_attribs}
          assert_redirected_to dmail_path(Dmail.last)
        end
      end
    end

    context "update action" do
      should "allow deletion if the dmail is owned by the current user" do
        put_auth dmail_path(@dmail), @user, params: { dmail: { is_deleted: true } }

        assert_redirected_to dmail_path(@dmail)
        assert_equal(true, @dmail.reload.is_deleted)
      end

      should "not allow deletion if the dmail is not owned by the current user" do
        put_auth dmail_path(@dmail), @unrelated_user, params: { dmail: { is_deleted: true } }

        assert_response 403
        assert_equal(false, @dmail.reload.is_deleted)
      end
    end
  end
end
