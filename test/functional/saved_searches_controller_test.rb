require 'test_helper'

class SavedSearchesControllerTest < ActionDispatch::IntegrationTest
  context "The saved searches controller" do
    setup do
      @user = create(:user)
      @saved_search = create(:saved_search, user: @user)
      SavedSearch.stubs(:redis).returns(MockRedis.new)
    end

    context "index action" do
      should "render" do
        get_auth saved_searches_path, @user
        assert_response :success
        assert_select "#saved-search-#{@saved_search.id}"
      end
    end

    context "labels action" do
      should "render" do
        get_auth labels_saved_searches_path, @user, as: :json
        assert_response :success
      end
    end

    context "create action" do
      should "render" do
        post_auth saved_searches_path, @user, params: { saved_search: { query: "bkub", label_string: "artist" }}
        assert_redirected_to SavedSearch.last
      end

      should "disable labels when the disable_labels param is given" do
        post_auth saved_searches_path, @user, params: { saved_search: { query: "bkub", disable_labels: "1" }}
        assert_redirected_to SavedSearch.last
        assert_equal(true, @user.reload.disable_categorized_saved_searches)
      end
    end

    context "edit action" do
      should "render" do
        @saved_search = create(:saved_search, user: @user)
        get_auth edit_saved_search_path(@saved_search), @user, params: { id: @saved_search.id }
        assert_response :success
      end
    end

    context "update action" do
      should "render" do
        put_auth saved_search_path(@saved_search), @user, params: { saved_search: { label_string: "foo" }}
        assert_redirected_to saved_searches_path
        assert_equal(["foo"], @saved_search.reload.labels)
      end

      should "not allow users to update saved searches belonging to other users" do
        put_auth saved_search_path(@saved_search), create(:user), params: { saved_search: { label_string: "foo" }}
        assert_response 403
        assert_not_equal(["foo"], @saved_search.reload.labels)
      end
    end

    context "destroy action" do
      should "render" do
        @saved_search = create(:saved_search, user: @user)
        assert_difference("SavedSearch.count", -1) do
          delete_auth saved_search_path(@saved_search), @user
          assert_redirected_to saved_searches_path
        end
      end

      should "not allow users to destroy saved searches belonging to other users" do
        @saved_search = create(:saved_search, user: @user)
        assert_difference("SavedSearch.count", 0) do
          delete_auth saved_search_path(@saved_search), create(:user)
          assert_response 403
        end
      end
    end
  end
end
