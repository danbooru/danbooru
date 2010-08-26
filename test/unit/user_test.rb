require_relative '../test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    user = Factory.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A user" do
    should "not validate if the originating ip address is banned" do
      Factory.create(:ip_ban)
      user = Factory.build(:user)
      user.save
      assert(user.errors.any?)
      assert_equal("IP address is banned", user.errors.full_messages.join)
    end
    
    should "limit post uploads" do
      user = Factory.create(:user)
      assert(!user.can_upload?)
      user.update_attribute(:is_contributor, true)
      assert(user.can_upload?)
      user.update_attribute(:is_contributor, false)
      
      40.times do
        Factory.create(:removed_post, :uploader => user)
      end
      
      assert(!user.can_upload?)
    end
    
    should "limit comment votes" do
      user = Factory.create(:user)
      assert(user.can_comment_vote?)
      12.times do
        Factory.create(:comment_vote, :user => user)
      end
      assert(!user.can_comment_vote?)
      CommentVote.update_all("created_at = '1990-01-01'")
      assert(user.can_comment_vote?)
    end
    
    should "limit comments" do
      user = Factory.create(:user)
      assert(!user.can_comment?)
      user.update_attribute(:is_privileged, true)
      assert(user.can_comment?)
      user.update_attribute(:is_privileged, false)
      user.update_attribute(:created_at, 1.year.ago)
      assert(user.can_comment?)
      (Danbooru.config.member_comment_limit + 1).times do
        Factory.create(:comment, :creator => user)
      end
      assert(!user.can_comment?)
    end
    
    should "verify" do
      user = Factory.create(:user)
      assert(user.is_verified?)
      user = Factory.create(:user)
      user.generate_email_verification_key
      user.save
      assert(!user.is_verified?)
      assert_raise(User::Error) {user.verify!("bbb")}
      assert_nothing_raised {user.verify!(user.email_verification_key)}
      assert(user.is_verified?)
    end
      
    should "authenticate" do
      @user = Factory.create(:user)
      assert(User.authenticate(@user.name, "password"), "Authentication should have succeeded")
      assert(!User.authenticate(@user.name, "password2"), "Authentication should not have succeeded")
      assert(User.authenticate_hash(@user.name, @user.password_hash), "Authentication should have succeeded")
      assert(!User.authenticate_hash(@user.name, "xxxx"), "Authentication should not have succeeded")
    end
      
    should "normalize its level" do
      user = Factory.create(:user, :is_admin => true)
      assert(user.is_moderator?)
      assert(user.is_janitor?)
      assert(user.is_contributor?)
      assert(user.is_privileged?)
    
      user = Factory.create(:user, :is_moderator => true)      
      assert(!user.is_admin?)
      assert(user.is_moderator?)
      assert(user.is_janitor?)
      assert(!user.is_contributor?)
      assert(user.is_privileged?)
    
      user = Factory.create(:user, :is_janitor => true)      
      assert(!user.is_admin?)
      assert(!user.is_moderator?)
      assert(user.is_janitor?)
      assert(!user.is_contributor?)
      assert(user.is_privileged?)
    
      user = Factory.create(:user, :is_contributor => true)      
      assert(!user.is_admin?)
      assert(!user.is_moderator?)
      assert(!user.is_janitor?)
      assert(user.is_contributor?)
      assert(user.is_privileged?)
    
      user = Factory.create(:user, :is_privileged => true)      
      assert(!user.is_admin?)
      assert(!user.is_moderator?)
      assert(!user.is_janitor?)
      assert(!user.is_contributor?)
      assert(user.is_privileged?)
    
      user = Factory.create(:user)      
      assert(!user.is_admin?)
      assert(!user.is_moderator?)
      assert(!user.is_janitor?)
      assert(!user.is_contributor?)
      assert(!user.is_privileged?)
    end
      
    context "name" do
      should "be #{Danbooru.config.default_guest_name} given an invalid user id" do
        assert_equal(Danbooru.config.default_guest_name, User.id_to_name(-1))
      end
    
      should "be fetched given a user id" do
        @user = Factory.create(:user)
        assert_equal(@user.name, User.id_to_name(@user.id))
      end
    
      should "be updated" do
        @user = Factory.create(:user)
        @user.update_attribute(:name, "danzig")
        assert_equal("danzig", User.id_to_name(@user.id))
      end
    end
      
    context "password" do
      should "match the confirmation" do
        @user = Factory.create(:user)
        @user.password = "zugzug5"
        @user.password_confirmation = "zugzug5"
        @user.save
        @user.reload
        assert(User.authenticate(@user.name, "zugzug5"), "Authentication should have succeeded")
      end
      
      should "match the confirmation" do
        @user = Factory.create(:user)
        @user.password = "zugzug6"
        @user.password_confirmation = "zugzug5"
        @user.save
        assert_equal(["Password doesn't match confirmation"], @user.errors.full_messages)
      end
      
      should "not be too short" do
        @user = Factory.create(:user)
        @user.password = "x5"
        @user.password_confirmation = "x5"
        @user.save
        assert_equal(["Password is too short (minimum is 5 characters)"], @user.errors.full_messages)
      end
      
      should "should be reset" do
        @user = Factory.create(:user)
        new_pass = @user.reset_password
        assert(User.authenticate(@user.name, new_pass), "Authentication should have succeeded")
      end
    end
  end
end
