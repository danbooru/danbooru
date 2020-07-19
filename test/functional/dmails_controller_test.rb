require 'test_helper'

class DmailsControllerTest < ActionDispatch::IntegrationTest
  context "The dmails controller" do
    setup do
      @user = create(:user, id: 999, unread_dmail_count: 1)
      @unrelated_user = create(:moderator_user, id: 1000, name: "reimu")
      @dmail = create(:dmail, owner: @user, from: @user)
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
        should "not allow users to quote dmails belonging to unrelated users " do
          get_auth new_dmail_path, @unrelated_user, params: {:respond_to_id => @dmail.id}
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
      setup do
        CurrentUser.user = @user
        @received_dmail = create(:dmail, owner: @user, body: "blah", to: @user, from: @unrelated_user, is_read: true)
        @deleted_dmail = create(:dmail, owner: @user, title: "UMAD", to: @unrelated_user, from: @user, is_deleted: true)
        @unrelated_dmail = create(:dmail, owner: @unrelated_user, from: @unrelated_user)
      end

      should "render" do
        get_auth dmails_path, @user
        assert_response :success
      end

      should respond_to_search({}).with { [@deleted_dmail, @received_dmail, @dmail] }
      should respond_to_search(folder: "sent").with { @dmail }
      should respond_to_search(folder: "received").with { @received_dmail }
      should respond_to_search(title_matches: "UMAD").with { @deleted_dmail }
      should respond_to_search(message_matches: "blah").with { @received_dmail }
      should respond_to_search(is_read: "true").with { @received_dmail }
      should respond_to_search(is_deleted: "true").with { @deleted_dmail }

      context "using includes" do
        should respond_to_search(to_id: 1000).with { @deleted_dmail }
        should respond_to_search(from_id: 999).with { [@deleted_dmail, @dmail] }
        should respond_to_search(from_name: "reimu").with { @received_dmail }
        should respond_to_search(from: {level: User::Levels::MODERATOR}).with { @received_dmail }
      end

      context "as a banned user" do
        setup do
          as(create(:admin_user)) do
            create(:ban, user: @user)
          end

          should respond_to_search({}).with { [@received_dmail, @dmail] }
        end
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

      should "show dmails not owned by the current user when given a valid key" do
        get_auth dmail_path(@dmail, key: @dmail.key), @unrelated_user
        assert_response :success
      end

      should "not show dmails not owned by the current user when given an invalid key" do
        get_auth dmail_path(@dmail, key: @dmail.key + "blah"), @unrelated_user
        assert_response 403
      end

      should "mark dmails as read" do
        assert_equal(false, @dmail.is_read)
        get_auth dmail_path(@dmail), @dmail.owner

        assert_response :success
        assert_equal(true, @dmail.reload.is_read)
      end

      should "not mark dmails as read in the api" do
        assert_equal(false, @dmail.is_read)
        get_auth dmail_path(@dmail, format: :json), @dmail.owner

        assert_response :success
        assert_equal(false, @dmail.reload.is_read)
      end

      should "not mark dmails as read when viewing dmails owned by another user" do
        assert_equal(false, @dmail.is_read)
        get_auth dmail_path(@dmail, key: @dmail.key), @unrelated_user

        assert_response :success
        assert_equal(false, @dmail.reload.is_read)
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

      should "send an email if the recipient has email notifications turned on" do
        recipient = create(:user, receive_email_notifications: true, email_address: build(:email_address))
        post_auth dmails_path, @user, params: { dmail: { to_name: recipient.name, title: "test", body: "test" }}

        assert_redirected_to Dmail.last
        assert_enqueued_emails 1
      end

      should "not allow banned users to send dmails" do
        create(:ban, user: @user)
        @user.reload

        assert_difference("Dmail.count", 0) do
          post_auth dmails_path, @user, params: { dmail: { to_id: @unrelated_user.id, title: "abc", body: "abc" }}
          assert_response 403
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

      should "not allow updating if the dmail is not owned by the current user even with a dmail key" do
        put_auth dmail_path(@dmail), @unrelated_user, params: { dmail: { is_deleted: true }, key: @dmail.key }

        assert_response 403
        assert_equal(false, @dmail.reload.is_deleted)
      end

      should "update user's unread_dmail_count when marking dmails as read or unread" do
        put_auth dmail_path(@dmail), @user, params: { dmail: { is_read: true } }
        assert_equal(true, @dmail.reload.is_read)
        assert_equal(0, @user.reload.unread_dmail_count)

        put_auth dmail_path(@dmail), @user, params: { dmail: { is_read: false } }
        assert_equal(false, @dmail.reload.is_read)
        assert_equal(1, @user.reload.unread_dmail_count)
      end
    end

    context "mark all as read action" do
      setup do
        @sender = create(:user)
        @recipient = create(:user)

        @dmail1 = create(:dmail, from: @sender, owner: @recipient, to: @recipient)
        @dmail2 = create(:dmail, from: @sender, owner: @recipient, to: @recipient)
        @dmail3 = create(:dmail, from: @sender, owner: @recipient, to: @recipient, is_read: true)
        @dmail4 = create(:dmail, from: @sender, owner: @recipient, to: @recipient, is_deleted: true)
      end

      should "mark all unread, undeleted dmails as read" do
        assert_equal(4, @recipient.dmails.count)
        assert_equal(2, @recipient.dmails.active.unread.count)
        assert_equal(2, @recipient.reload.unread_dmail_count)
        post_auth mark_all_as_read_dmails_path(format: :js), @recipient

        assert_response :success
        assert_equal(0, @recipient.reload.unread_dmail_count)
        assert_equal(true, [@dmail1, @dmail2, @dmail3, @dmail4].map(&:reload).all?(&:is_read))
      end
    end

    context "when a user has unread dmails" do
      should "show the unread dmail notice" do
        get_auth posts_path, @user

        assert_response :success
        assert_select "#dmail-notice", 1
        assert_select "#nav-my-account-link", text: "My Account (1)"
      end

      should "not show the unread dmail notice after closing it" do
        cookies[:hide_dmail_notice] = @user.dmails.active.unread.first.id
        get_auth posts_path, @user

        assert_response :success
        assert_select "#dmail-notice", 0
        assert_select "#nav-my-account-link", text: "My Account (1)"
      end
    end
  end
end
