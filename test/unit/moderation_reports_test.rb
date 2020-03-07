require 'test_helper'

class ModerationReportTest < ActiveSupport::TestCase
  context "Moderation reports: " do
    context "creating a moderation report" do
      should "create a forum post" do
        @dmail = create(:dmail)
        @modreport = create(:moderation_report, model: @dmail, reason: "blah")

        assert_equal(2, ForumPost.count)
        assert_match(/blah/, ForumPost.last.body)
      end
    end
  end
end
