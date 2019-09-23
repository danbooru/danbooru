require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "A user" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "promoting a user" do
      setup do
        CurrentUser.user = FactoryBot.create(:moderator_user)
      end

      should "create a neutral feedback" do
        assert_difference("UserFeedback.count") do
          @user.promote_to!(User::Levels::GOLD)
        end

        assert_equal("You have been promoted to a Gold level account from Member.", @user.feedback.last.body)
      end

      should "send an automated dmail to the user" do
        bot = FactoryBot.create(:user)
        User.stubs(:system).returns(bot)

        assert_difference("Dmail.count", 1) do
          @user.promote_to!(User::Levels::GOLD)
        end

        assert(@user.dmails.exists?(from: bot, to: @user, title: "You have been promoted"))
        refute(@user.dmails.exists?(from: bot, to: @user, title: "Your user record has been updated"))
      end
    end

    should "not validate if the originating ip address is banned" do
      CurrentUser.scoped(User.anonymous, "1.2.3.4") do
        create(:ip_ban, ip_addr: '1.2.3.4')
        user = build(:user, last_ip_addr: '1.2.3.4')
        refute(user.valid?)
        assert_equal("IP address is banned", user.errors.full_messages.join)
      end
    end

    should "limit post uploads" do
      assert(!@user.can_upload?)
      @user.update_column(:created_at, 15.days.ago)
      assert(@user.can_upload?)
      assert_equal(10, @user.upload_limit)

      9.times do
        FactoryBot.create(:post, :uploader => @user, :is_pending => true)
      end

      @user = User.find(@user.id)
      assert_equal(1, @user.upload_limit)
      assert(@user.can_upload?)
      FactoryBot.create(:post, :uploader => @user, :is_pending => true)
      @user = User.find(@user.id)
      assert(!@user.can_upload?)
    end

    should "limit comment votes" do
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      Danbooru.config.stubs(:member_comment_limit).returns(10)
      assert(@user.can_comment_vote?)
      10.times do
        comment = FactoryBot.create(:comment)
        FactoryBot.create(:comment_vote, :comment_id => comment.id, :score => -1)
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
        FactoryBot.create(:comment)
      end
      assert(@user.is_comment_limited?)
    end

    should "authenticate" do
      assert(User.authenticate(@user.name, "password"), "Authentication should have succeeded")
      assert(!User.authenticate(@user.name, "password2"), "Authentication should not have succeeded")
      assert(User.authenticate_hash(@user.name, User.sha1("password")), "Authentication should have succeeded")
      assert(!User.authenticate_hash(@user.name, User.sha1("xxx")), "Authentication should not have succeeded")
    end

    should "normalize its level" do
      user = FactoryBot.create(:user, :level => User::Levels::ADMIN)
      assert(user.is_moderator?)
      assert(user.is_gold?)

      user = FactoryBot.create(:user, :level => User::Levels::MODERATOR)
      assert(!user.is_admin?)
      assert(user.is_moderator?)
      assert(user.is_gold?)

      user = FactoryBot.create(:user, :level => User::Levels::GOLD)
      assert(!user.is_admin?)
      assert(!user.is_moderator?)
      assert(user.is_gold?)

      user = FactoryBot.create(:user)
      assert(!user.is_admin?)
      assert(!user.is_moderator?)
      assert(!user.is_gold?)
    end

    context "name" do
      should "not contain whitespace" do
        # U+2007: https://en.wikipedia.org/wiki/Figure_space
        user = FactoryBot.build(:user, :name => "foo\u2007bar")
        user.save
        assert_equal(["Name cannot have whitespace or colons"], user.errors.full_messages)
      end

      should "not contain a colon" do
        user = FactoryBot.build(:user, :name => "a:b")
        user.save
        assert_equal(["Name cannot have whitespace or colons"], user.errors.full_messages)
      end

      should "not begin with an underscore" do
        user = FactoryBot.build(:user, :name => "_x")
        user.save
        assert_equal(["Name cannot begin or end with an underscore"], user.errors.full_messages)
      end

      should "not end with an underscore" do
        user = FactoryBot.build(:user, :name => "x_")
        user.save
        assert_equal(["Name cannot begin or end with an underscore"], user.errors.full_messages)
      end

      should "be updated" do
        @user = FactoryBot.create(:user)
        @user.update_attribute(:name, "danzig")
      end
    end

    context "searching for users by name" do
      setup do
        @miku = create(:user, name: "hatsune_miku")
      end

      should "be case-insensitive" do
        assert_equal("hatsune_miku", User.normalize_name("Hatsune_Miku"))
        assert_equal(@miku.id, User.find_by_name("Hatsune_Miku").id)
        assert_equal(@miku.id, User.name_to_id("Hatsune_Miku"))
      end

      should "handle whitespace" do
        assert_equal("hatsune_miku", User.normalize_name(" hatsune miku "))
        assert_equal(@miku.id, User.find_by_name(" hatsune miku ").id)
        assert_equal(@miku.id, User.name_to_id(" hatsune miku "))
      end

      should "return nil for nonexistent names" do
        assert_nil(User.find_by_name("does_not_exist"))
        assert_nil(User.name_to_id("does_not_exist"))
      end

      should "work for names containing asterisks or backlashes" do
        @user1 = create(:user, name: "user*1")
        @user2 = create(:user, name: "user*2")
        @user3 = create(:user, name: "user\*3")

        assert_equal(@user1.id, User.find_by_name("user*1").id)
        assert_equal(@user2.id, User.find_by_name("user*2").id)
        assert_equal(@user3.id, User.find_by_name("user\*3").id)
      end
    end

    context "ip address" do
      setup do
        @user = FactoryBot.create(:user)
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
        @user = FactoryBot.create(:user)
        @user.password = "zugzug5"
        @user.password_confirmation = "zugzug5"
        @user.save
        @user.reload
        assert(User.authenticate_cookie_hash(@user.name, @user.bcrypt_cookie_password_hash))
      end

      should "match the confirmation" do
        @user = FactoryBot.create(:user)
        @user.old_password = "password"
        @user.password = "zugzug5"
        @user.password_confirmation = "zugzug5"
        @user.save
        @user.reload
        assert(User.authenticate(@user.name, "zugzug5"), "Authentication should have succeeded")
      end

      should "fail if the confirmation does not match" do
        @user = FactoryBot.create(:user)
        @user.password = "zugzug6"
        @user.password_confirmation = "zugzug5"
        @user.save
        assert_equal(["Password confirmation doesn't match Password"], @user.errors.full_messages)
      end

      should "not be too short" do
        @user = FactoryBot.create(:user)
        @user.password = "x5"
        @user.password_confirmation = "x5"
        @user.save
        assert_equal(["Password is too short (minimum is 5 characters)"], @user.errors.full_messages)
      end

      should "should be reset" do
        @user = FactoryBot.create(:user)
        new_pass = @user.reset_password
        assert(User.authenticate(@user.name, new_pass), "Authentication should have succeeded")
      end

      should "not change the password if the password and old password are blank" do
        @user = FactoryBot.create(:user, :password => "67890")
        @user.update(password: "", old_password: "")
        assert(@user.bcrypt_password == User.sha1("67890"))
      end

      should "not change the password if the old password is incorrect" do
        @user = FactoryBot.create(:user, :password => "67890")
        @user.update(password: "12345", old_password: "abcdefg")
        assert(@user.bcrypt_password == User.sha1("67890"))
      end

      should "not change the password if the old password is blank" do
        @user = FactoryBot.create(:user, :password => "67890")
        @user.update(password: "12345", old_password: "")
        assert(@user.bcrypt_password == User.sha1("67890"))
      end

      should "change the password if the old password is correct" do
        @user = FactoryBot.create(:user, :password => "67890")
        @user.update(password: "12345", old_password: "67890")
        assert(@user.bcrypt_password == User.sha1("12345"))
      end

      context "in the json representation" do
        setup do
          @user = FactoryBot.create(:user)
        end

        should "not appear" do
          assert(@user.to_json !~ /password/)
        end
      end

      context "in the xml representation" do
        setup do
          @user = FactoryBot.create(:user)
        end

        should "not appear" do
          assert(@user.to_xml !~ /password/)
        end
      end
    end

    context "that might be a sock puppet" do
      setup do
        @user = FactoryBot.create(:user, last_ip_addr: "127.0.0.2")
        Danbooru.config.unstub(:enable_sock_puppet_validation?)
      end

      should "not validate" do
        CurrentUser.scoped(nil, "127.0.0.2") do
          @user = FactoryBot.build(:user)
          @user.save
          assert_equal(["Last ip addr was used recently for another account and cannot be reused for another day"], @user.errors.full_messages)
        end
      end
    end

    context "when searched by name" do
      should "match wildcards" do
        user1 = FactoryBot.create(:user, :name => "foo")
        user2 = FactoryBot.create(:user, :name => "foo*bar")
        user3 = FactoryBot.create(:user, :name => "bar\*baz")

        assert_equal([user2.id, user1.id], User.search(name: "foo*").map(&:id))
        assert_equal([user2.id], User.search(name: "foo\*bar").map(&:id))
        assert_equal([user3.id], User.search(name: "bar\\\*baz").map(&:id))
      end
    end
  end
end
