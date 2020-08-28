require 'test_helper'

class DmailTest < ActiveSupport::TestCase
  context "A dmail" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "1.2.3.4"
    end

    teardown do
      CurrentUser.user = nil
    end

    context "that is spam" do
      should "be automatically reported and deleted" do
        @recipient = create(:user)
        @spammer = create(:user, created_at: 2.weeks.ago, email_address: build(:email_address, address: "akismet-guaranteed-spam@example.com"))

        SpamDetector.stubs(:enabled?).returns(true)
        dmail = create(:dmail, owner: @recipient, from: @spammer, to: @recipient, creator_ip_addr: "127.0.0.1")

        assert_equal(1, dmail.moderation_reports.count)
        assert_equal(true, dmail.reload.is_deleted?)
      end
    end

    context "search" do
      should "return results based on title contents" do
        dmail = FactoryBot.create(:dmail, :title => "xxx", :owner => @user)

        matches = Dmail.search(title_matches: "x*")
        assert_equal([dmail.id], matches.map(&:id))

        matches = Dmail.search(title_matches: "X*")
        assert_equal([dmail.id], matches.map(&:id))

        matches = Dmail.search(message_matches: "xxx")
        assert_equal([dmail.id], matches.map(&:id))

        matches = Dmail.search(message_matches: "aaa")
        assert(matches.empty?)
      end

      should "return results based on body contents" do
        dmail = FactoryBot.create(:dmail, :body => "xxx", :owner => @user)
        matches = Dmail.search(message_matches: "xxx")
        assert(matches.any?)
        matches = Dmail.search(message_matches: "aaa")
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
        Dmail.create_split(from: CurrentUser.user, creator_ip_addr: "127.0.0.1", to: @new_user, title: "foo", body: "foo")
      end
    end

    should "notify the recipient he has mail" do
      recipient = create(:user)

      create(:dmail, owner: recipient, to: recipient)
      assert_equal(1, recipient.reload.unread_dmail_count)

      recipient.dmails.unread.last.update!(is_read: true)
      assert_equal(0, recipient.reload.unread_dmail_count)
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
          assert_equal(["must exist"], dmail.errors[:to])
        end
      end
    end

    context "sending a dmail" do
      should "fail if the user has sent too many dmails recently" do
        10.times do
          Dmail.create_split(from: @user, to: create(:user), title: "blah", body: "blah", creator_ip_addr: "127.0.0.1")
        end

        assert_no_difference("Dmail.count") do
          @dmail = Dmail.create_split(from: @user, to: create(:user), title: "blah", body: "blah", creator_ip_addr: "127.0.0.1")

          assert_equal(false, @dmail.valid?)
          assert_equal(["You can't send dmails to more than 10 users per hour"], @dmail.errors[:base])
        end
      end
    end

    context "destroying a dmail" do
      setup do
        @recipient = create(:user)
        @dmail = Dmail.create_split(from: @user, to: @recipient, creator_ip_addr: "127.0.0.1", title: "foo", body: "foo")
        @modreport = create(:moderation_report, model: @dmail)
      end

      should "update both users' unread dmail counts" do
        assert_equal(0, @user.reload.unread_dmail_count)
        assert_equal(1, @recipient.reload.unread_dmail_count)

        @user.dmails.last.destroy!
        @recipient.dmails.last.destroy!

        assert_equal(0, @user.reload.unread_dmail_count)
        assert_equal(0, @recipient.reload.unread_dmail_count)
      end

      should "destroy any associated moderation reports" do
        assert_equal(1, @dmail.moderation_reports.count)
        @dmail.destroy!
        assert_equal(0, @dmail.moderation_reports.count)
      end
    end

    context "during validation" do
      subject { FactoryBot.build(:dmail) }

      should_not allow_value(" ").for(:title)
      should_not allow_value(" ").for(:body)
      should_not allow_value(nil).for(:to)
      should_not allow_value(nil).for(:from)
      should_not allow_value(nil).for(:owner)
    end
  end
end
