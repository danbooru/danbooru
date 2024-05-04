require 'test_helper'

class MetricsControllerTest < ActionDispatch::IntegrationTest
  context "The metrics controller" do
    context "#index action" do
      setup do
        as(create(:user)) do
          create(:artist)
          create(:artist_url)
          create(:bulk_update_request)
          create(:comment)
          create(:comment_vote)
          create(:favorite_group)
          create(:forum_post)
          create(:forum_topic)
          create(:media_asset)
          create(:post_appeal)
          create(:post_flag)
          create(:note)
          create(:pool)
          create(:tag)
          create(:upload)
          create(:user_feedback)
          create(:wiki_page)
        end
      end

      should "work for text format" do
        get metrics_path

        assert_response :success
      end

      should "work for json format" do
        get metrics_path(format: :json)

        assert_response :success
      end

      should "work for xml format" do
        get metrics_path(format: :json)

        assert_response :success
      end
    end

    context "#instance action" do
      should "work for text format" do
        ApplicationMetrics.update_process_metrics
        get instance_metrics_path

        assert_response :success
      end
    end
  end
end
