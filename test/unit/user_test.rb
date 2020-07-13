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

        assert(@user.dmails.exists?(from: bot, to: @user, title: "Your account has been updated"))
        refute(@user.dmails.exists?(from: bot, to: @user, title: "Your user record has been updated"))
      end
    end

    should "authenticate password" do
      assert_equal(@user, @user.authenticate_password("password"))
      assert_equal(false, @user.authenticate_password("password2"))
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

      should "not allow blacklisted names" do
        Danbooru.config.stubs(:user_name_blacklist).returns(["voldemort"])
        user = build(:user, name: "voldemort42")
        user.save
        assert_equal(["Name is not allowed"], user.errors.full_messages)
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
