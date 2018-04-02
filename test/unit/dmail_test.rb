require 'test_helper'

class DmailTest < ActiveSupport::TestCase
  context "A dmail" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "1.2.3.4"
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
    end

    teardown do
      CurrentUser.user = nil
    end

    context "spam" do
      setup do
        Dmail.any_instance.stubs(:spam?).returns(true)
        @recipient = FactoryBot.create(:user)
      end

      should "not validate" do
        assert_difference("Dmail.count", 2)do
          Dmail.create_split(:to_id => @recipient.id, :title => "My video", :body => "hey Noneeditsonlyme.  My webcam see here http://bit.ly/2vTv9Ki")
          assert(@recipient.dmails.last.is_spam?)
        end
      end

      should "autoban spammers after sending spam to N distinct users" do
        Dmail.any_instance.expects(:spam?).returns(true)

        users = FactoryBot.create_list(:user, Dmail::AUTOBAN_THRESHOLD)
        users.each do |user|
          Dmail.create_split(from: @user, to: user, title: "spam", body: "wonderful spam")
        end

        assert_equal(true, Dmail.is_spammer?(@user))
        assert_equal(true, @user.reload.is_banned)
        assert_equal(1, @user.bans.count)
        assert_match(/Spambot./, @user.bans.last.reason)
      end
    end

    context "filter" do
      setup do
        @recipient = FactoryBot.create(:user)
        @recipient.create_dmail_filter(:words => "banned")
        @dmail = FactoryBot.build(:dmail, :title => "xxx", :owner => @recipient, :body => "banned word here", :to => @recipient, :from => @user)
      end

      should "detect banned words" do
        assert(@recipient.dmail_filter.filtered?(@dmail))
      end

      should "autoread if it has a banned word" do
        @dmail.save
        assert_equal(true, @dmail.is_read?)
      end

      should "not update the recipient's has_mail if filtered" do
        @dmail.save
        @recipient.reload
        assert_equal(false, @recipient.has_mail?)
      end

      should "be ignored when sender is a moderator" do
        CurrentUser.scoped(FactoryBot.create(:moderator_user), "127.0.0.1") do
          @dmail = FactoryBot.create(:dmail, :owner => @recipient, :body => "banned word here", :to => @recipient)
        end

        assert_equal(false, !!@recipient.dmail_filter.filtered?(@dmail))
        assert_equal(false, @dmail.is_read?)
        assert_equal(true, @recipient.has_mail?)
      end

      context "that is empty" do
        setup do
          @recipient.dmail_filter.update_attributes(:words => "   ")
        end

        should "not filter everything" do
          assert(!@recipient.dmail_filter.filtered?(@dmail))
        end
      end
    end

    context "from a banned user" do
      setup do
        @user.update_attribute(:is_banned, true)
      end

      should "not validate" do
        dmail = FactoryBot.build(:dmail, :title => "xxx", :owner => @user)
        dmail.save
        assert_equal(1, dmail.errors.size)
        assert_equal(["Sender is banned and cannot send messages"], dmail.errors.full_messages)
      end
    end

    context "search" do
      should "return results based on title contents" do
        dmail = FactoryBot.create(:dmail, :title => "xxx", :owner => @user)

        matches = Dmail.search(title_matches: "x")
        assert_equal([dmail.id], matches.map(&:id))

        matches = Dmail.search(title_matches: "X")
        assert_equal([dmail.id], matches.map(&:id))

        matches = Dmail.search(message_matches: "xxx")
        assert_equal([dmail.id], matches.map(&:id))

        matches = Dmail.search(message_matches: "aaa")
        assert(matches.empty?)
      end

      should "return results based on body contents" do
        dmail = FactoryBot.create(:dmail, :body => "xxx", :owner => @user)
        matches = Dmail.search_message("xxx")
        assert(matches.any?)
        matches = Dmail.search_message("aaa")
        assert(matches.empty?)
      end
    end

    should "should parse user names" do
      dmail = FactoryBot.build(:dmail, :owner => @user)
      dmail.to_id = nil
      dmail.to_name = @user.name
      assert(dmail.to_id == @user.id)
    end

    should "construct a response" do
      dmail = FactoryBot.create(:dmail, :owner => @user)
      response = dmail.build_response
      assert_equal("Re: #{dmail.title}", response.title)
      assert_equal(dmail.from_id, response.to_id)
      assert_equal(dmail.to_id, response.from_id)
    end

    should "create a copy for each user" do
      @new_user = FactoryBot.create(:user)
      assert_difference("Dmail.count", 2) do
        Dmail.create_split(:to_id => @new_user.id, :title => "foo", :body => "foo")
      end
    end

    should "record the creator's ip addr" do
      dmail = FactoryBot.create(:dmail, owner: @user)
      assert_equal(CurrentUser.ip_addr, dmail.creator_ip_addr.to_s)
    end

    should "send an email if the user wants it" do
      user = FactoryBot.create(:user, :receive_email_notifications => true)
      assert_difference("ActionMailer::Base.deliveries.size", 1) do
        FactoryBot.create(:dmail, :to => user, :owner => user)
      end
    end

    should "create only one message for a split response" do
      user = FactoryBot.create(:user, :receive_email_notifications => true)
      assert_difference("ActionMailer::Base.deliveries.size", 1) do
        Dmail.create_split(:to_id => user.id, :title => "foo", :body => "foo")
      end
    end

    should "be marked as read after the user reads it" do
      dmail = FactoryBot.create(:dmail, :owner => @user)
      assert(!dmail.is_read?)
      dmail.mark_as_read!
      assert(dmail.is_read?)
    end

    should "notify the recipient he has mail" do
      @recipient = FactoryBot.create(:user)
      dmail = FactoryBot.create(:dmail, :owner => @recipient)
      recipient = dmail.to
      recipient.reload
      assert(recipient.has_mail?)

      CurrentUser.scoped(recipient) do
        dmail.mark_as_read!
      end

      recipient.reload
      assert(!recipient.has_mail?)
    end

    context "that is automated" do
      setup do
        @bot = FactoryBot.create(:user)
        User.stubs(:system).returns(@bot)
      end

      should "only create a copy for the recipient" do
        Dmail.create_automated(to: @user, title: "test", body: "test")

        assert @user.dmails.exists?(from: @bot, title: "test", body: "test")
        assert !@bot.dmails.exists?(from: @bot, title: "test", body: "test")
      end

      should "fail gracefully if recipient doesn't exist" do
        assert_nothing_raised do
          dmail = Dmail.create_automated(to_name: "this_name_does_not_exist", title: "test", body: "test")
          assert_equal(["can't be blank"], dmail.errors[:to_id])
        end
      end
    end
  end
end
