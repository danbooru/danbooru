require "test_helper"

class ModerationReportTest < ActiveSupport::TestCase
  context "A moderation report" do
    setup do
      @reporter = create(:user)
      @mod = create(:moderator_user)
      @spammer = create(:user)
      @comment = create(:comment, creator: @spammer)
      @report = create(:moderation_report, model: @comment, creator: @reporter)
    end

    should "notify the reporter and create a handled mod action when marked handled" do
      @report.updater = @mod

      assert_difference(["Dmail.count", "ModAction.count"], 1) do
        @report.update!(status: :handled)
      end

      assert_equal(true, @reporter.dmails.received.exists?(from: User.system, title: "Thank you for reporting comment ##{@comment.id}"))

      mod_action = ModAction.moderation_report_handled.last
      assert_equal(@report, mod_action.subject)
      assert_equal(@mod, mod_action.creator)
    end

    should "create a rejected mod action without notifying the reporter when marked rejected" do
      @report.updater = @mod

      assert_difference("ModAction.count", 1) do
        assert_no_difference("Dmail.count") do
          @report.update!(status: :rejected)
        end
      end

      mod_action = ModAction.moderation_report_rejected.last
      assert_equal(@report, mod_action.subject)
      assert_equal(@mod, mod_action.creator)
    end

    context "when normalizing the reason" do
      should normalize_attribute(:reason).from(" ").to("")
      should normalize_attribute(:reason).from("  \u200B  ").to("")
      should normalize_attribute(:reason).from(" foo ").to("foo")
      should normalize_attribute(:reason).from("foo\tbar").to("foo bar")
      should normalize_attribute(:reason).from("foo\nbar").to("foo\r\nbar")
      should normalize_attribute(:reason).from("Pokémon".unicode_normalize(:nfd)).to("Pokémon".unicode_normalize(:nfc))
    end
  end
end
