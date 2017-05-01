require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "A user" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "promoting a user" do
      setup do
        CurrentUser.user = FactoryGirl.create(:moderator_user)
      end

      should "create a neutral feedback" do
        assert_difference("UserFeedback.count") do
          @user.promote_to!(User::Levels::GOLD)
        end

        assert_equal("You have been promoted to a Gold level account from Member.", @user.feedback.last.body)
      end

      should "send an automated dmail to the user" do
        bot = FactoryGirl.create(:user)
        Danbooru.config.stubs(:system_user).returns(bot)

        assert_difference("Dmail.count", 1) do
          @user.promote_to!(User::Levels::GOLD)
        end

        assert(@user.dmails.exists?(from: bot, to: @user, title: "You have been promoted"))
      end
    end

    context "favoriting a post" do
      setup do
        @user.update_column(:favorite_count, 999)
        @user.stubs(:clean_favorite_count?).returns(true)
        @post = FactoryGirl.create(:post)
      end

      should "periodically clean the favorite_count" do
        @user.add_favorite!(@post)
        assert_equal(1, @user.favorite_count)
      end
    end

    context "that has been invited by a mod" do
      setup do
        @mod = FactoryGirl.create(:moderator_user)
      end

      should "work" do
        @user.invite!(User::Levels::BUILDER, "1")
        @user.reload
        assert_equal(User::Levels::BUILDER, @user.level)
        assert_equal(true, @user.can_upload_free)
      end

      should "create a mod action" do
        assert_difference("ModAction.count") do
          @user.invite!(User::Levels::BUILDER, "1")
        end
        assert_equal(%{"#{@user.name}":/users/#{@user.id} level changed Member -> Builder}, ModAction.last.description)
      end
    end

    should "not validate if the originating ip address is banned" do
      FactoryGirl.create(:ip_ban)
      user = FactoryGirl.build(:user)
      user.save
      assert(user.errors.any?)
      assert_equal("IP address is banned", user.errors.full_messages.join)
    end

    should "limit post uploads" do
      assert(!@user.can_upload?)
      @user.update_column(:created_at, 15.days.ago)
      assert(@user.can_upload?)
      assert_equal(10, @user.upload_limit)

      9.times do
        FactoryGirl.create(:post, :uploader => @user, :is_pending => true)
      end

      @user = User.find(@user.id)
      assert_equal(1, @user.upload_limit)
      assert(@user.can_upload?)
      FactoryGirl.create(:post, :uploader => @user, :is_pending => true)
      @user = User.find(@user.id)
      assert(!@user.can_upload?)
    end

    should "limit comment votes" do
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      Danbooru.config.stubs(:member_comment_limit).returns(10)
      assert(@user.can_comment_vote?)
      10.times do
        comment = FactoryGirl.create(:comment)
        FactoryGirl.create(:comment_vote, :comment_id => comment.id, :score => -1)
      end

      assert(!@user.can_comment_vote?)
      CommentVote.update_all("created_at = '1990-01-01'")
      assert(@user.can_comment_vote?)
    end

    should "limit comments" do
      assert(!@user.can_comment?)
      @user.update_column(:level, User::Levels::GOLD)
      assert(@user.can_comment?)
      @user.update_column(:level, User::Levels::MEMBER)
      @user.update_column(:created_at, 1.year.ago)
      assert(@user.can_comment?)
      assert(!@user.is_comment_limited?)
      (Danbooru.config.member_comment_limit).times do
        FactoryGirl.create(:comment)
      end
      assert(@user.is_comment_limited?)
    end

    should "verify" do
      assert(@user.is_verified?)
      @user = FactoryGirl.create(:user)
      @user.generate_email_verification_key
      @user.save
      assert(!@user.is_verified?)
      assert_raise(User::Error) {@user.verify!("bbb")}
      assert_nothing_raised {@user.verify!(@user.email_verification_key)}
      assert(@user.is_verified?)
    end

    should "authenticate" do
      assert(User.authenticate(@user.name, "password"), "Authentication should have succeeded")
      assert(!User.authenticate(@user.name, "password2"), "Authentication should not have succeeded")
      assert(User.authenticate_hash(@user.name, User.sha1("password")), "Authentication should have succeeded")
      assert(!User.authenticate_hash(@user.name, User.sha1("xxx")), "Authentication should not have succeeded")
    end

    should "normalize its level" do
      user = FactoryGirl.create(:user, :level => User::Levels::ADMIN)
      assert(user.is_moderator?)
      assert(user.is_gold?)

      user = FactoryGirl.create(:user, :level => User::Levels::MODERATOR)
      assert(!user.is_admin?)
      assert(user.is_moderator?)
      assert(user.is_gold?)

      user = FactoryGirl.create(:user, :level => User::Levels::GOLD)
      assert(!user.is_admin?)
      assert(!user.is_moderator?)
      assert(user.is_gold?)

      user = FactoryGirl.create(:user)
      assert(!user.is_admin?)
      assert(!user.is_moderator?)
      assert(!user.is_gold?)
    end

    context "name" do
      should "be #{Danbooru.config.default_guest_name} given an invalid user id" do
        assert_equal(Danbooru.config.default_guest_name, User.id_to_name(-1))
      end

      should "not contain whitespace" do
        # U+2007: https://en.wikipedia.org/wiki/Figure_space
        user = FactoryGirl.build(:user, :name => "foo\u2007bar")
        user.save
        assert_equal(["Name cannot have whitespace or colons"], user.errors.full_messages)
      end

      should "not contain a colon" do
        user = FactoryGirl.build(:user, :name => "a:b")
        user.save
        assert_equal(["Name cannot have whitespace or colons"], user.errors.full_messages)
      end

      should "not begin with an underscore" do
        user = FactoryGirl.build(:user, :name => "_x")
        user.save
        assert_equal(["Name cannot begin or end with an underscore"], user.errors.full_messages)
      end

      should "not end with an underscore" do
        user = FactoryGirl.build(:user, :name => "x_")
        user.save
        assert_equal(["Name cannot begin or end with an underscore"], user.errors.full_messages)
      end

      should "be fetched given a user id" do
        @user = FactoryGirl.create(:user)
        assert_equal(@user.name, User.id_to_name(@user.id))
      end

      should "be updated" do
        @user = FactoryGirl.create(:user)
        @user.update_attribute(:name, "danzig")
        assert_equal(@user.name, User.id_to_name(@user.id))
      end
    end

    context "ip address" do
      setup do
        @user = FactoryGirl.create(:user)
      end

      context "in the json representation" do
        should "not appear" do
          assert(@user.to_json !~ /addr/)
        end
      end

      context "in the xml representation" do
        should "not appear" do
          assert(@user.to_xml !~ /addr/)
        end
      end
    end

    context "password" do
      should "match the cookie hash" do
        @user = FactoryGirl.create(:user)
        @user.password = "zugzug5"
        @user.password_confirmation = "zugzug5"
        @user.save
        @user.reload
        assert(User.authenticate_cookie_hash(@user.name, @user.bcrypt_cookie_password_hash))
      end

      should "match the confirmation" do
        @user = FactoryGirl.create(:user)
        @user.old_password = "password"
        @user.password = "zugzug5"
        @user.password_confirmation = "zugzug5"
        @user.save
        @user.reload
        assert(User.authenticate(@user.name, "zugzug5"), "Authentication should have succeeded")
      end

      should "fail if the confirmation does not match" do
        @user = FactoryGirl.create(:user)
        @user.password = "zugzug6"
        @user.password_confirmation = "zugzug5"
        @user.save
        assert_equal(["Password confirmation doesn't match Password"], @user.errors.full_messages)
      end

      should "not be too short" do
        @user = FactoryGirl.create(:user)
        @user.password = "x5"
        @user.password_confirmation = "x5"
        @user.save
        assert_equal(["Password is too short (minimum is 5 characters)"], @user.errors.full_messages)
      end

      should "should be reset" do
        @user = FactoryGirl.create(:user)
        new_pass = @user.reset_password
        assert(User.authenticate(@user.name, new_pass), "Authentication should have succeeded")
      end

      should "not change the password if the password and old password are blank" do
        @user = FactoryGirl.create(:user, :password => "67890")
        @user.update_attributes(:password => "", :old_password => "")
        assert(@user.bcrypt_password == User.sha1("67890"))
      end

      should "not change the password if the old password is incorrect" do
        @user = FactoryGirl.create(:user, :password => "67890")
        @user.update_attributes(:password => "12345", :old_password => "abcdefg")
        assert(@user.bcrypt_password == User.sha1("67890"))
      end

      should "not change the password if the old password is blank" do
        @user = FactoryGirl.create(:user, :password => "67890")
        @user.update_attributes(:password => "12345", :old_password => "")
        assert(@user.bcrypt_password == User.sha1("67890"))
      end

      should "change the password if the old password is correct" do
        @user = FactoryGirl.create(:user, :password => "67890")
        @user.update_attributes(:password => "12345", :old_password => "67890")
        assert(@user.bcrypt_password == User.sha1("12345"))
      end

      context "in the json representation" do
        setup do
          @user = FactoryGirl.create(:user)
        end

        should "not appear" do
          assert(@user.to_json !~ /password/)
        end
      end

      context "in the xml representation" do
        setup do
          @user = FactoryGirl.create(:user)
        end

        should "not appear" do
          assert(@user.to_xml !~ /password/)
        end
      end
    end
  end
end
