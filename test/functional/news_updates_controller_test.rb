require 'test_helper'

class NewsUpdatesControllerTest < ActionDispatch::IntegrationTest
  context "the news updates controller" do
    setup do
      @admin = create(:admin_user)
      as(@admin) do
        @news_update = create(:news_update, creator: @admin)
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
        assert_difference("NewsUpdate.active.count", -1) do
          delete_auth news_update_path(@news_update), @admin
        end
        assert(@news_update.reload.is_deleted)
        assert_redirected_to(news_updates_path)
      end
    end

    context "undelete action" do
      should "work" do
        @news_update.update_column(:is_deleted, true)

        assert_difference("NewsUpdate.active.count", 1) do
          post_auth undelete_news_update_path(@news_update), @admin
        end
        refute(@news_update.reload.is_deleted)
        assert_redirected_to(news_updates_path)
      end
    end
  end
end
