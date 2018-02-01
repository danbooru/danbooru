require 'test_helper'

class SavedSearchesControllerTest < ActionController::TestCase
  context "The saved searches controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      mock_saved_search_service!
    end

    context "index action" do
      should "render" do
        get :index, {}, { user_id: @user.id }
        assert_response :success
      end
    end

    context "create action" do
      should "render" do
        post :create, { saved_search: { query: "bkub", label_string: "artist" }}, { user_id: @user.id }
        assert_response :redirect
      end

      should "disable labels when the disable_labels param is given" do
        post :create, { saved_search: { query: "bkub", disable_labels: "1" }}, { user_id: @user.id }
        assert_equal(true, @user.reload.disable_categorized_saved_searches)
      end
    end

    context "edit action" do
      should "render" do
        saved_search = FactoryGirl.create(:saved_search, user: @user)

        get :edit, { id: saved_search.id }, { user_id: @user.id }
        assert_response :success
      end
    end

    context "update action" do
      should "render" do
        saved_search = FactoryGirl.create(:saved_search, user: @user)
        params = { id: saved_search.id, saved_search: { label_string: "foo" } }

        put :update, params, { user_id: @user.id }
        assert_redirected_to saved_searches_path
        assert_equal(["foo"], saved_search.reload.labels)
      end
    end

    context "destroy action" do
      should "render" do
        saved_search = FactoryGirl.create(:saved_search, user: @user)

        delete :destroy, { id: saved_search.id }, { user_id: @user.id }
        assert_redirected_to saved_searches_path
      end
    end
  end
end
