require "test_helper"

class SpamDetectorTest < ActiveSupport::TestCase
  context "SpamDetector" do
    setup do
      skip "SpamDetector not working: API key not configured, not valid, or akismet is down" if !SpamDetector.working?
      SpamDetector.stubs(:enabled?).returns(true)

      @user = create(:gold_user, created_at: 1.month.ago)
      @spammer = create(:user, created_at: 2.weeks.ago, email_address: build(:email_address, address: "akismet-guaranteed-spam@example.com"))
    end

    context "for dmails" do
      should "detect spam" do
        Dmail.create_split(from: @spammer, to: @user, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        dmail = @user.dmails.last
        assert(SpamDetector.new(dmail).spam?)
      end

      should "not detect gold users as spammers" do
        Dmail.create_split(from: @user, to: @spammer, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        dmail = @spammer.dmails.last
        refute(SpamDetector.new(dmail).spam?)
      end

      should "not detect old users as spammers" do
        @spammer.update!(created_at: 2.months.ago)
        Dmail.create_split(from: @user, to: @spammer, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        dmail = @spammer.dmails.last
        refute(SpamDetector.new(dmail).spam?)
      end

      should "generate a moderation report when spam is detected" do
        Dmail.create_split(from: @spammer, to: @user, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")
        assert_equal(1, @user.dmails.last.moderation_reports.count)
      end

      should "pass messages through if akismet is down" do
        Rakismet.stubs(:akismet_call).raises(StandardError)
        dmail = create(:dmail, from: @spammer, to: @user, owner: @user, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        refute(SpamDetector.new(dmail).spam?)
      end

      should "autoban the user if they send too many spam dmails" do
        count = SpamDetector::AUTOBAN_THRESHOLD
        dmails = create_list(:dmail, count, from: @spammer, to: @user, owner: @user, creator_ip_addr: "127.0.0.1")

        assert_equal(count, ModerationReport.where(model: Dmail.sent_by(@spammer)).count)
        assert_equal(true, @spammer.reload.is_banned?)
      end
    end

    context "for forum posts" do
      setup do
        @forum_topic = as(@user) { create(:forum_topic) }
      end

      should "generate a moderation report when spam is detected" do
        as(@spammer) do
          forum_post = create(:forum_post, creator: @spammer, topic: @forum_topic)

          assert(SpamDetector.new(forum_post, user_ip: "127.0.0.1").spam?)
          assert_equal(1, forum_post.moderation_reports.count)
        end
      end

      should "not detect gold users as spammers" do
        as(@user) do
          forum_post = create(:forum_post, creator: @user, topic: @forum_topic)

          refute(SpamDetector.new(forum_post).spam?)
          assert_equal(0, forum_post.moderation_reports.count)
        end
      end
    end

    context "for comments" do
      should "generate a moderation report when spam is detected" do
        as(@spammer) do
          comment = create(:comment, creator: @spammer)

          assert(SpamDetector.new(comment).spam?)
          assert_equal(1, comment.moderation_reports.count)
        end
      end

      should "not detect gold users as spammers" do
        as(@user) do
          comment = create(:comment, creator: @user)

          refute(SpamDetector.new(comment).spam?)
          assert_equal(0, comment.moderation_reports.count)
        end
      end
    end
  end
end
