require "test_helper"

class ForumTopicVisitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @visit = as(@user) { create(:forum_topic_visit, user: @user) }
    @mod_user = create(:moderator_user)
    @mod_visit = as(@mod_user) { create(:forum_topic_visit, user: @mod_user) }
  end

  context "index action" do
    should "work for json responses" do
      get_auth forum_topic_visits_path, @user, as: :json

      assert_equal([@visit.id], response.parsed_body.pluck("id"))
      assert_response :success
    end

    should "only show the current user's forum topic visits to other users" do
      get_auth forum_topic_visits_path, @mod_user, as: :json

      assert_response :success
      assert_equal([@mod_visit.id], response.parsed_body.pluck("id"))
    end

    should "show all forum topic visits to a superadmin" do
      get_auth forum_topic_visits_path, create(:superadmin_user), as: :json

      assert_response :success
      assert_equal([@mod_visit.id, @visit.id], response.parsed_body.pluck("id"))
    end
  end
end
