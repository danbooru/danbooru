require 'test_helper'

class ModerationReportsControllerTest < ActionDispatch::IntegrationTest
  context "The moderation reports controller" do
    setup do
      @user = create(:user, created_at: 2.weeks.ago)
      @spammer = create(:user, id: 5678, name: "spammer", created_at: 2.weeks.ago)
      @mod = create(:moderator_user, created_at: 2.weeks.ago)

      as(@spammer) do
        @dmail = create(:dmail, from: @spammer, owner: @user, to: @user)
        @comment = create(:comment, id: 1234, creator: @spammer)
        @forum_post = create(:forum_post, topic: build(:forum_topic), body: "xxx", creator: @spammer)
      end
    end

    context "new action" do
      should "render the access denied page for anonymous users" do
        get new_moderation_report_path
        assert_response 403
      end

      should "render" do
        get_auth new_moderation_report_path, @user, params: {:moderation_report => {:model_id => @comment.id, :model_type => "Comment"}}
        assert_response :success
      end

      should "not raise an exception when given an invalid model" do
        @user = create(:user)
        get_auth new_moderation_report_path(moderation_report: { model_type: "User", model_id: @user.id }), @user
        assert_response 403
      end
    end

    context "index action" do
      setup do
        @comment_report = create(:moderation_report, model: @comment, creator: @user)
        @forum_report = create(:moderation_report, model: @forum_post, creator: @user)
        @dmail_report = create(:moderation_report, reason: "spam", model: @dmail, creator: build(:builder_user, name: "daiyousei", created_at: 2.weeks.ago))
      end

      context "as a user" do
        should "show reports submitted by the current user" do
          get_auth moderation_reports_path, @user

          assert_response :success
          assert_select "tbody tr", count: 2
          assert_select "tr#moderation-report-#{@comment_report.id}", count: 1
          assert_select "tr#moderation-report-#{@forum_report.id}", count: 1
          assert_select "tr#moderation-report-#{@dmail_report.id}", count: 0
        end

        should "not show reports submitted by other users" do
          get_auth moderation_reports_path, create(:user)

          assert_response :success
          assert_select "tbody tr", count: 0
        end
      end

      context "as a moderator" do
        setup do
          CurrentUser.user = @mod
        end

        should "render" do
          get_auth moderation_reports_path, @mod
          assert_response :success
        end

        should respond_to_search({}).with { [@dmail_report, @forum_report, @comment_report] }
        should respond_to_search(reason_matches: "spam").with { @dmail_report }
        should respond_to_search(recipient_id: 5678).with { [@dmail_report, @forum_report, @comment_report] }
        should respond_to_search(recipient_name: "spammer").with { [@dmail_report, @forum_report, @comment_report] }

        context "using includes" do
          should respond_to_search(model_id: 1234).with { @comment_report }
          should respond_to_search(model_type: "ForumPost").with { @forum_report }
          should respond_to_search(ForumPost: {body_matches: "xxx"}).with { @forum_report }
          should respond_to_search(creator_name: "daiyousei").with { @dmail_report }
        end
      end
    end

    context "show action" do
      should "redirect" do
        @report = create(:moderation_report, model: @comment, creator: @user)
        get_auth moderation_report_path(@report), @mod
        assert_redirected_to moderation_reports_path(search: { id: @report.id })
      end
    end

    context "create action" do
      should "create a new moderation report on a comment" do
        assert_difference("ModerationReport.count", 1) do
          post_auth moderation_reports_path, @user, params: {:format => "js", :moderation_report => {:model_id => @comment.id, :model_type => "Comment", :reason => "xxx"}}
          assert_response :success
        end
      end

      should "create a new moderation report on a forum post" do
        assert_difference("ModerationReport.count", 1) do
          post_auth moderation_reports_path, @user, params: { format: "js", moderation_report: { model_id: @forum_post.id, model_type: "ForumPost", reason: "xxx" }}
          assert_response :success
        end
      end

      should "create a new moderation report on a dmail" do
        assert_difference("ModerationReport.count", 1) do
          post_auth moderation_reports_path, @user, params: { format: "js", moderation_report: { model_id: @dmail.id, model_type: "Dmail", reason: "xxx" }}
          assert_response :success
        end
      end
    end

    context "update action" do
      should "not allow non-mods to update moderation reports" do
        report = create(:moderation_report, model: @comment, creator: @user)
        put_auth moderation_report_path(report), @user, params: { moderation_report: { status: "handled" }}, xhr: true

        assert_response 403
      end

      should "allow a moderator to mark a moderation report as handled" do
        report = create(:moderation_report, model: @comment, creator: @user)
        put_auth moderation_report_path(report), @mod, params: { moderation_report: { status: "handled" }}, xhr: true

        assert_response :success
        assert_equal("handled", report.reload.status)
        assert_equal(true, @user.dmails.received.exists?(from: User.system, title: "Thank you for reporting comment ##{@comment.id}"))
        assert_equal(true, ModAction.moderation_report_handled.where(creator: @mod).exists?)
        assert_equal(report, ModAction.last.subject)
        assert_equal(@mod, ModAction.last.creator)
      end

      should "allow a moderator to mark a moderation report as rejected" do
        report = create(:moderation_report, model: @comment, creator: @user)
        put_auth moderation_report_path(report), @mod, params: { moderation_report: { status: "rejected" }}, xhr: true

        assert_response :success
        assert_equal("rejected", report.reload.status)
        assert_equal(false, @user.dmails.received.exists?(from: User.system))
        assert_equal(true, ModAction.moderation_report_rejected.where(creator: @mod).exists?)
        assert_equal(report, ModAction.last.subject)
        assert_equal(@mod, ModAction.last.creator)
      end
    end
  end
end
