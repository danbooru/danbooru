require 'test_helper'

class NewsUpdatesControllerTest < ActionDispatch::IntegrationTest
  context "the news updates controller" do
    setup do
      @admin = create(:admin_user)
      as(@admin) do
        @news_update = create(:news_update)
      end
    end

    context "index action" do
      should "render" do
        get_auth news_updates_path, @admin
        assert_response :success
      end
    end

    context "new action" do
      should "render" do
        get_auth new_news_update_path, @admin
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_news_update_path(@news_update), @admin
        assert_response :success
      end
    end

    context "update action" do
      should "work" do
        put_auth news_update_path(@news_update), @admin, params: {:news_update => {:message => "zzz"}}
        assert_redirected_to(news_updates_path)
      end
    end

    context "create action" do
      should "work" do
        assert_difference("NewsUpdate.count") do
          post_auth news_updates_path, @admin, params: {:news_update => {:message => "zzz"}}
        end
        assert_redirected_to(news_updates_path)
      end
    end

    context "destroy action" do
      should "work" do
        assert_difference("NewsUpdate.count", -1) do
          delete_auth news_update_path(@news_update), @admin
        end
        assert_redirected_to(news_updates_path)
      end
    end
  end
end
