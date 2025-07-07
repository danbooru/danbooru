require "test_helper"

class NewsUpdatesControllerTest < ActionDispatch::IntegrationTest
  context "the news updates controller" do
    setup do
      @admin = create(:admin_user)
    end

    context "index action" do
      should "render for an admin" do
        create(:news_update)
        get_auth news_updates_path, @admin

        assert_response :success
      end

      should "not render for a regular user" do
        get_auth news_updates_path, create(:user)
        assert_response 403
      end
    end

    context "show action" do
      should "render for an admin" do
        @news_update = create(:news_update)
        get_auth news_update_path(@news_update), @admin

        assert_redirected_to news_updates_path(search: { id: @news_update.id })
      end

      should "not render for a regular user" do
        @news_update = create(:news_update)
        get_auth news_update_path(@news_update), create(:user)

        assert_response 403
      end
    end

    context "new action" do
      should "render for an admin" do
        get_auth new_news_update_path, @admin
        assert_response :success
      end

      should "not render for a regular user" do
        get_auth new_news_update_path, create(:user)
        assert_response 403
      end
    end

    context "edit action" do
      should "render for an admin" do
        @news_update = create(:news_update, creator: @admin)
        get_auth edit_news_update_path(@news_update), @admin

        assert_response :success
      end

      should "not render for a regular user" do
        @news_update = create(:news_update, creator: @admin)
        get_auth edit_news_update_path(@news_update), create(:user)

        assert_response 403
      end
    end

    context "update action" do
      should "work for an admin" do
        @news_update = create(:news_update, creator: @admin)
        @other_admin = create(:admin_user)
        put_auth news_update_path(@news_update), @other_admin, params: { news_update: { message: "zzz" }}

        assert_redirected_to(news_updates_path)
        assert_equal(@admin, @news_update.reload.creator)
        assert_equal(@other_admin, @news_update.updater)
        assert_equal(true, @news_update.mod_actions.news_update_update.exists?)

        get_auth posts_path, @admin
        assert_select "#news-updates > div", count: 1, text: "zzz"
      end

      should "not work for a regular user" do
        @news_update = create(:news_update)
        put_auth news_update_path(@news_update), create(:user), params: { news_update: { message: "zzz" }}

        assert_response 403
      end
    end

    context "create action" do
      should "work for an admin" do
        assert_difference("NewsUpdate.active.count") do
          post_auth news_updates_path, @admin, params: { news_update: { message: "zzz"}}
        end

        assert_redirected_to(news_updates_path)
        @news_update = NewsUpdate.last
        assert_equal(@admin, @news_update.creator)
        assert_equal(@admin, @news_update.updater)
        assert_equal(true, @news_update.mod_actions.news_update_create.exists?)

        get_auth posts_path, @admin
        assert_select "#news-updates > div", count: 1, text: "zzz"
      end

      should "not work for a regular user" do
        post_auth news_updates_path, create(:user), params: { news_update: { message: "zzz" }}
        assert_response 403
      end
    end

    context "delete action" do
      should "work" do
        @news_update = create(:news_update, creator: @admin)
        @other_admin = create(:admin_user)

        assert_difference("NewsUpdate.active.count", -1) do
          delete_auth news_update_path(@news_update), @other_admin
        end

        assert_redirected_to(news_updates_path)
        assert_equal(@admin, @news_update.reload.creator)
        assert_equal(@other_admin, @news_update.updater)
        assert_equal(true, @news_update.mod_actions.news_update_delete.exists?)

        get_auth posts_path, @admin
        assert_select "#news-updates > div", count: 0
      end

      should "not work for a regular user" do
        @news_update = create(:news_update)
        delete_auth news_update_path(@news_update), create(:user)

        assert_response 403
      end
    end

    context "undelete action" do
      should "work for an admin" do
        @news_update = create(:news_update, creator: @admin, is_deleted: true)
        @other_admin = create(:admin_user)

        put_auth news_update_path(@news_update), @other_admin, params: { news_update: { is_deleted: false } }

        assert_redirected_to(news_updates_path)
        assert_equal(@admin, @news_update.reload.creator)
        assert_equal(@other_admin, @news_update.updater)
        assert_equal(true, @news_update.mod_actions.news_update_undelete.exists?)

        get_auth posts_path, @admin
        assert_select "#news-updates > div", count: 1, text: @news_update.message
      end

      should "not work for a regular user" do
        @news_update = create(:news_update)
        put_auth news_update_path(@news_update), create(:user), params: { news_update: { is_deleted: false } }

        assert_response 403
      end
    end
  end
end
