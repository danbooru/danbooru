require "test_helper"

class SpamDetectorTest < ActiveSupport::TestCase
  context "SpamDetector" do
    setup do
      skip "SpamDetector not working: API key not configured, not valid, or akismet is down" if !SpamDetector.working?
      SpamDetector.stubs(:enabled?).returns(true)

      @user = create(:gold_user, created_at: 1.month.ago)
      @spammer = create(:user, created_at: 2.weeks.ago, email: "akismet-guaranteed-spam@example.com")
    end

    context "for dmails" do
      should "detect spam" do
        Dmail.create_split(from: @spammer, to: @user, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        dmail = @user.dmails.last
        assert(SpamDetector.new(dmail).spam?)
        assert(dmail.is_spam?)
      end

      should "not detect gold users as spammers" do
        Dmail.create_split(from: @user, to: @spammer, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        dmail = @spammer.dmails.last
        refute(SpamDetector.new(dmail).spam?)
        refute(dmail.is_spam?)
      end

      should "not detect old users as spammers" do
        @spammer.update!(created_at: 2.months.ago)
        Dmail.create_split(from: @user, to: @spammer, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        dmail = @spammer.dmails.last
        refute(SpamDetector.new(dmail).spam?)
        refute(dmail.is_spam?)
      end

      should "log a message when spam is detected" do
        Rails.logger.expects(:info)
        Dmail.create_split(from: @spammer, to: @user, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")
      end

      should "pass messages through if akismet is down" do
        Rakismet.expects(:akismet_call).raises(StandardError)
        dmail = create(:dmail, from: @spammer, to: @user, owner: @user, title: "spam", body: "wonderful spam", creator_ip_addr: "127.0.0.1")

        refute(SpamDetector.new(dmail).spam?)
      end
    end

    context "for forum posts" do
      setup do
        @forum_topic = as(@user) { create(:forum_topic) }
      end

      should "detect spam" do
        as(@spammer) do
          forum_post = build(:forum_post, topic: @forum_topic)
          forum_post.validate

          assert(SpamDetector.new(forum_post, user_ip: "127.0.0.1").spam?)
          assert(forum_post.invalid?)
          assert_equal(["Failed to create forum post"], forum_post.errors.full_messages)
        end
      end

      should "not detect gold users as spammers" do
        as(@user) do
          forum_post = create(:forum_post, topic: @forum_topic)

          refute(SpamDetector.new(forum_post).spam?)
          assert(forum_post.valid?)
        end
      end
    end

    context "for comments" do
      should "detect spam" do
        as(@spammer) do
          comment = build(:comment)
          comment.validate

          assert(SpamDetector.new(comment).spam?)
          assert(comment.invalid?)
          assert_equal(["Failed to create comment"], comment.errors.full_messages)
        end
      end

      should "not detect gold users as spammers" do
        as(@user) do
          comment = create(:comment)

          refute(SpamDetector.new(comment).spam?)
          assert(comment.valid?)
        end
      end
    end
  end
end
