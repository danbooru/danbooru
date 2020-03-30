require "test_helper"

class ForumTopicVisitsControllerTest < ActionDispatch::IntegrationTest
  context "index action" do
    should "work for json responses" do
      @user = create(:user)
      @visit = as(@user) { create(:forum_topic_visit, user: @user) }
      get_auth forum_topic_visits_path, @user, as: :json

      assert_response :success
    end
  end
end
