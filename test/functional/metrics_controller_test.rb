require 'test_helper'

class MetricsControllerTest < ActionDispatch::IntegrationTest
  context "The metrics controller" do
    context "#index action" do
      setup do
        as(create(:user)) do
          create(:artist)
          create(:artist_commentary)
          create(:artist_commentary_version)
          create(:artist_url)
          create(:ban)
          create(:bulk_update_request)
          create(:comment)
          create(:comment_vote)
          create(:dtext_link)
          create(:favorite_group)
          create(:forum_post)
          create(:forum_post_vote)
          create(:forum_topic)
          create(:media_asset)
          create(:mod_action)
          create(:post_appeal)
          create(:post_approval)
          create(:post_flag)
          create(:post_replacement)
          create(:note)
          create(:pool)
          create(:pool_version)
          create(:saved_search)
          create(:tag)
          create(:tag_alias)
          create(:tag_implication)
          create(:tag_version)
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
