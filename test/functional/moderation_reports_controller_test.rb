require 'test_helper'

class ModerationReportsControllerTest < ActionDispatch::IntegrationTest
  context "The moderation reports controller" do
    setup do
      @user = create(:user, created_at: 2.weeks.ago)
      @spammer = create(:user, created_at: 2.weeks.ago)
      @mod = create(:moderator_user, created_at: 2.weeks.ago)

      @spammer.as_current do
        @comment = create(:comment, creator: @spammer)
      end
    end

    context "new action" do
      should "render the access denied page" do
        get_auth new_moderation_report_path, User.anonymous
        assert_response 403
        assert_select "h1", /Access Denied/
      end

      should "render" do
        get_auth new_moderation_report_path, @user, params: {:moderation_report => {:model_id => @comment.id, :model_type => "Comment"}}
        assert_response :success
      end
    end

    context "index action" do
      setup do
        create(:moderation_report, model: @comment, creator: @user)
      end

      should "render the access denied page" do
        get_auth moderation_reports_path, @user
        assert_response 403
        assert_select "h1", /Access Denied/
      end

      should "render" do
        get_auth moderation_reports_path, @mod
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_auth moderation_reports_path, @mod, params: {:search => {:model_id => @comment.id}}
          assert_response :success
        end
      end
    end

    context "create action" do
      should "create a new moderation report" do
        assert_difference("ModerationReport.count", 1) do
          post_auth moderation_reports_path, @user, params: {:format => "js", :moderation_report => {:model_id => @comment.id, :model_type => "Comment", :reason => "xxx"}}
          assert_response :success
        end
      end
    end
  end
end
