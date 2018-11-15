require 'test_helper'

class SavedSearchesControllerTest < ActionDispatch::IntegrationTest
  context "The saved searches controller" do
    setup do
      SavedSearch.stubs(:enabled?).returns(true)
      @user = create(:user)
      as_user do
        @saved_search = create(:saved_search, user: @user)
      end
      mock_saved_search_service!
    end

    context "index action" do
      should "render" do
        get_auth saved_searches_path, @user
        assert_response :success
        assert_select "#saved-search-#{@saved_search.id}"
      end
    end

    context "create action" do
      should "render" do
        post_auth saved_searches_path, @user, params: { saved_search: { query: "bkub", label_string: "artist" }}
        assert_response :redirect
      end

      should "disable labels when the disable_labels param is given" do
        post_auth saved_searches_path, @user, params: { saved_search: { query: "bkub", disable_labels: "1" }}
        assert_equal(true, @user.reload.disable_categorized_saved_searches)
      end
    end

    context "edit action" do
      should "render" do
        as_user do
          @saved_search = create(:saved_search, user: @user)
        end

        get_auth edit_saved_search_path(@saved_search), @user, params: { id: @saved_search.id }
        assert_response :success
      end
    end

    context "update action" do
      should "render" do
        as_user do
          @saved_search = create(:saved_search, user: @user)
        end
        params = { id: @saved_search.id, saved_search: { label_string: "foo" } }
        put_auth saved_search_path(@saved_search), @user, params: params
        assert_redirected_to saved_searches_path
        assert_equal(["foo"], @saved_search.reload.labels)
      end
    end

    context "destroy action" do
      should "render" do
        as_user do
          @saved_search = create(:saved_search, user: @user)
        end

        delete_auth saved_search_path(@saved_search), @user
        assert_redirected_to saved_searches_path
      end
    end
  end
end
