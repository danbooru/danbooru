require 'test_helper'

class UserDeletionTest < ActiveSupport::TestCase
  context "an invalid user deletion" do
    context "for an invalid password" do
      should "fail" do
        @user = create(:user)
        @deletion = UserDeletion.new(@user, "wrongpassword")
        @deletion.delete!
        assert_includes(@deletion.errors[:base], "Password is incorrect")
      end
    end

    context "for an admin" do
      should "fail" do
        @user = create(:admin_user)
        @deletion = UserDeletion.new(@user, "password")
        @deletion.delete!
        assert_includes(@deletion.errors[:base], "Admins cannot delete their account")
      end
    end
  end

  context "a valid user deletion" do
    setup do
      @user = create(:user, name: "foo", email_address: build(:email_address))
      @deletion = UserDeletion.new(@user, "password")
    end

    should "blank out the email" do
      @deletion.delete!
      assert_nil(@user.reload.email_address)
    end

    should "rename the user" do
      @deletion.delete!
      assert_equal("user_#{@user.id}", @user.reload.name)
    end

    should "generate a user name change request" do
      assert_difference("UserNameChangeRequest.count") do
        @deletion.delete!
      end

      assert_equal("foo", UserNameChangeRequest.last.original_name)
      assert_equal("user_#{@user.id}", UserNameChangeRequest.last.desired_name)
    end

    should "reset the password" do
      @deletion.delete!
      assert_equal(false, @user.authenticate_password("password"))
    end

    should "remove any favorites" do
      @post = create(:post)
      Favorite.add(post: @post, user: @user)

      perform_enqueued_jobs { @deletion.delete! }

      assert_equal(0, Favorite.count)
      assert_equal("", @post.reload.fav_string)
      assert_equal(0, @post.fav_count)
    end
  end
end
