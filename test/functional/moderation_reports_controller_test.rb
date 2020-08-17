require 'test_helper'

class ModerationReportsControllerTest < ActionDispatch::IntegrationTest
  context "The moderation reports controller" do
    setup do
      @user = create(:user, created_at: 2.weeks.ago)
      @spammer = create(:user, created_at: 2.weeks.ago)
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
    end

    context "index action" do
      setup do
        @comment_report = create(:moderation_report, model: @comment, creator: @user)
        @forum_report = create(:moderation_report, model: @forum_post, creator: @user)
        @dmail_report = create(:moderation_report, reason: "spam", model: @dmail, creator: build(:builder_user, name: "daiyousei", created_at: 2.weeks.ago))
      end

      context "as a user" do
        should "render the access denied page" do
          get_auth moderation_reports_path, @user
          assert_response 403
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
  end
end
