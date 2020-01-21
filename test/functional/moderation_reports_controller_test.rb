require 'test_helper'

class ModerationReportsControllerTest < ActionDispatch::IntegrationTest
  context "The moderation reports controller" do
    setup do
      travel_to(2.weeks.ago) do
        @user = create(:user)
        @builder = create(:builder_user)
        @mod = create(:moderator_user)
      end

      @user.as_current do
        @comment = create(:comment, creator: @user)
      end
    end

    context "new action" do
      should "render the access denied page" do
        get_auth new_moderation_report_path, @user
        assert_response 403
        assert_select "h1", /Access Denied/
      end

      should "render" do
        get_auth new_moderation_report_path, @mod, params: {:moderation_report => {:model_id => @comment.id, :model_type => "Comment"}}
        assert_response :success
      end
    end

    context "index action" do
      setup do
        create(:moderation_report, model: @comment, creator: @builder)
      end

      should "render the access denied page" do
        get_auth moderation_reports_path, @builder
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

      context "create action" do
        should "create a new moderation report" do
          assert_difference("ModerationReport.count", 1) do
            assert_difference("ModerationReport.count") do
              post_auth moderation_reports_path, @builder, params: {:format => "js", :moderation_report => {:model_id => @comment.id, :model_type => "Comment", :reason => "xxx"}}
            end
          end
        end
      end
    end
  end
end
