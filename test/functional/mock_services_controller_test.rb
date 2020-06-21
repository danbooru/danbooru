require 'test_helper'

class MockServicesControllerTest < ActionDispatch::IntegrationTest
  context "The mock services controller" do
    setup do
      create(:post)
      create(:tag)
    end

    context "for all actions" do
      should "work" do
        paths = [
          mock_recommender_recommend_path(42),
          mock_recommender_similar_path(42),
          mock_reportbooru_missed_searches_path,
          mock_reportbooru_post_searches_path,
          mock_reportbooru_post_views_path,
          mock_iqdbs_similar_path,
        ]

        paths.each do |path|
          get path
          assert_response :success
        end
      end
    end
  end
end
