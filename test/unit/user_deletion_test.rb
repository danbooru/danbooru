require 'test_helper'

class UserDeletionTest < ActiveSupport::TestCase
  context "an invalid user deletion" do
    context "for an invalid password" do
      setup do
        @user = FactoryBot.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        @deletion = UserDeletion.new(@user, "wrongpassword")
      end

      should "fail" do
        assert_raise(UserDeletion::ValidationError) do
          @deletion.delete!
        end
      end
    end

    context "for an admin" do
      setup do
        @user = FactoryBot.create(:admin_user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        @deletion = UserDeletion.new(@user, "password")
      end

      should "fail" do
        assert_raise(UserDeletion::ValidationError) do
          @deletion.delete!
        end
      end
    end
  end

  context "a valid user deletion" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @post = FactoryBot.create(:post)
      Favorite.add(post: @post, user: @user)

      @user.update_attributes(:email => "ted@danbooru.com")

      @deletion = UserDeletion.new(@user, "password")
      @deletion.delete!
      @user.reload
    end

    should "blank out the email" do
      assert_nil(@user.email)
    end

    should "rename the user" do
      assert_equal("user_#{@user.id}", @user.name)
    end

    should "reset the password" do
      assert_nil(User.authenticate(@user.name, "password"))
    end

    should "remove any favorites" do
      @post.reload
      assert_equal(0, Favorite.count)
      assert_equal("", @post.fav_string)
      assert_equal(0, @post.fav_count)
    end
  end
end
