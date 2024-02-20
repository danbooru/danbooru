require 'test_helper'

class UserDeletionTest < ActiveSupport::TestCase
  setup do
    @request = mock
    @request.stubs(:remote_ip).returns("1.1.1.1")
    @request.stubs(:user_agent).returns("Firefox")
    @request.stubs(:session).returns(session_id: "1234")
    @request.stubs(:query_parameters).returns({})
    @request.stubs(:delete).with(:user_id).returns(nil)
    @request.stubs(:delete).with(:last_authenticatd_at).returns(nil)
  end

  context "an invalid user deletion" do
    context "for an invalid password" do
      should "fail" do
        @user = create(:user)
        @deletion = UserDeletion.new(user: @user, password: "wrongpassword", request: @request)
        @deletion.delete!
        assert_includes(@deletion.errors[:base], "Password is incorrect")
        assert_equal(false, @user.reload.is_deleted)
      end
    end

    context "for an admin" do
      should "fail" do
        @user = create(:admin_user)
        @deletion = UserDeletion.new(user: @user, password: "password", request: @request)
        @deletion.delete!
        assert_includes(@deletion.errors[:base], "Admins cannot delete their account")
        assert_equal(false, @user.reload.is_deleted)
      end
    end

    context "for a banned user" do
      should "fail" do
        @user = create(:banned_user)
        @deletion = UserDeletion.new(user: @user, password: "password", request: @request)
        @deletion.delete!
        assert_includes(@deletion.errors[:base], "You cannot delete your account if you are banned")
        assert_equal(false, @user.reload.is_deleted)
      end
    end
  end

  context "a valid user deletion" do
    setup do
      @user = create(:gold_user, name: "foo", email_address: build(:email_address), totp_secret: TOTP.generate_secret, backup_codes: [1, 2, 3])
      @api_key = create(:api_key, user: @user)
      @favorite = create(:favorite, user: @user)
      @forum_topic_visit = as(@user) { create(:forum_topic_visit, user: @user) }
      @saved_search = create(:saved_search, user: @user)
      @public_favgroup = create(:favorite_group, creator: @user, is_public: true)
      @private_favgroup = create(:favorite_group, creator: @user, is_public: false)
      @post_downvote = create(:post_vote, score: -1)
      @post_upvote = create(:post_vote, score: 1)
      @deletion = UserDeletion.new(user: @user, password: "password", request: @request)
    end

    should "blank out the email" do
      perform_enqueued_jobs { @deletion.delete! }
      assert_nil(@user.reload.email_address)
    end

    should "rename the user" do
      @deletion.delete!
      assert_equal("user_#{@user.id}", @user.reload.name)
    end

    should "mark the user as deleted" do
      @deletion.delete!
      assert_equal(true, @user.reload.is_deleted)
    end

    should "generate a user name change request" do
      @deletion.delete!
      assert_equal(1, @user.user_name_change_requests.count)
      assert_equal("foo", @user.user_name_change_requests.last.original_name)
      assert_equal("user_#{@user.id}", @user.user_name_change_requests.last.desired_name)
    end

    should "reset the password" do
      @deletion.delete!
      assert_equal(false, @user.authenticate_password("password"))
    end

    should "destroy the 2FA secret and backup codes" do
      assert_equal(true, @user.totp_secret.present?)
      assert_equal(true, @user.backup_codes.present?)

      perform_enqueued_jobs { @deletion.delete! }

      assert_nil(@user.reload.totp_secret)
      assert_nil(@user.backup_codes)
    end

    should "not generate a modaction" do
      @deletion.delete!

      assert_equal(0, ModAction.user_delete.count)
    end

    should "remove the user's favorites if they have private favorites" do
      @user.update!(enable_private_favorites: true)
      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(0, @user.favorites.count)
      assert_equal(0, @user.reload.favorite_count)
    end

    should "not remove the user's favorites if they have public favorites" do
      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(1, @user.favorites.count)
      assert_equal(1, @user.favorite_count)
    end

    should "remove the user's API keys" do
      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(0, @user.api_keys.count)
    end

    should "remove the user's forum topic visits" do
      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(0, @user.forum_topic_visits.count)
    end

    should "remove the user's saved searches" do
      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(0, @user.saved_searches.count)
    end

    should "remove the user's private favgroups but not their public favgroups" do
      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(0, @user.favorite_groups.is_private.count)
      assert_equal(1, @user.favorite_groups.is_public.count)
      assert_not_nil(@public_favgroup.reload)
    end

    should "only remove the user's downvotes if the don't have private votes enabled" do
      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(0, @user.post_votes.active.negative.count)
      assert_equal(1, @user.post_votes.active.positive.count)
    end

    should "remove both the user's upvotes and downvotes if they have private votes enabled" do
      @user.update!(enable_private_favorites: true)
      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(0, @user.post_votes.active.negative.count)
      assert_equal(0, @user.post_votes.active.positive.count)
    end
  end

  context "deleting another user's account" do
    should "work for the owner-level user" do
      @user = create(:user)
      @deletion = UserDeletion.new(user: @user, deleter: create(:owner_user))

      @deletion.delete!
      assert_equal("user_#{@user.id}", @user.reload.name)
      assert_equal(true, @user.is_deleted)
      assert_equal("deleted user ##{@user.id}", ModAction.last.description)
      assert_equal(@deletion.deleter, ModAction.last.creator)
      assert_equal(@user, ModAction.last.subject)
      assert_equal(false, ModAction.user_name_change.exists?)
      assert_equal(1, ModAction.count)
    end

    should "not work for other users" do
      @user = create(:user)
      @deletion = UserDeletion.new(user: @user, deleter: create(:admin_user))

      @deletion.delete!
      assert_not_equal("user_#{@user.id}", @user.reload.name)
      assert_equal(false, @user.is_deleted)
      assert_equal(0, ModAction.count)
    end
  end

  context "undeleting a user's account" do
    should "restore the user's name and reset their password" do
      @user = create(:user, name: "fumimi", password: "hunter2")
      @deletion = UserDeletion.new(user: @user, deleter: create(:owner_user), password: "hunter2")

      @deletion.delete!
      assert_equal("user_#{@user.id}", @user.reload.name)
      assert_equal(true, @user.is_deleted)
      assert_equal(false, @user.authenticate_password("hunter2").present?)
      assert_equal("deleted user ##{@user.id}", ModAction.last.description)
      assert_equal("user_delete", ModAction.last.category)
      assert_equal(@deletion.deleter, ModAction.last.creator)
      assert_equal(@user, ModAction.last.subject)

      @deletion.undelete!
      assert_equal("fumimi", @user.reload.name)
      assert_equal(false, @user.is_deleted)
      assert_equal(true, @user.authenticate_password("hunter2").present?)
      assert_equal("undeleted user ##{@user.id}", ModAction.last.description)
      assert_equal("user_undelete", ModAction.last.category)
      assert_equal(@deletion.deleter, ModAction.last.creator)
      assert_equal(@user, ModAction.last.subject)
    end
  end
end
