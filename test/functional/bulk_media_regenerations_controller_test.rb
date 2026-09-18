require "test_helper"

class BulkMediaRegenerationsControllerTest < ActionDispatch::IntegrationTest
  context "The bulk media regenerations controller" do
    setup do
      @admin = create(:admin_user)
      @png = create(:media_asset, file_ext: "png")
      @jpg = create(:media_asset, file_ext: "jpg")
    end

    context "new action" do
      should "render" do
        get_auth new_bulk_media_regeneration_path, @admin

        assert_response :success
      end

      should "show the number of matching assets when a query is given" do
        get_auth new_bulk_media_regeneration_path, @admin, params: { search: { ai_tags_match: "filetype:png" }}

        assert_response :success
        assert_select "a.button-danger", text: "Regenerate 1 asset"
      end

      should "not allow non-admins to see the page" do
        get_auth new_bulk_media_regeneration_path, create(:mod_user)

        assert_response 403
      end

      should "show an error if the search is blank" do
        get_auth new_bulk_media_regeneration_path, @admin, params: { search: { ai_tags_match: "" }}

        assert_response :success
        assert_select "#a-new .notice-error", text: "You must enter a search query"
      end

      should "not show an error on the first visit to the page" do
        get_auth new_bulk_media_regeneration_path, @admin

        assert_response :success
        assert_select "#a-new .notice-error", count: 0
      end
    end

    context "create action" do
      should "log a mod action and schedule a regeneration job" do
        assert_difference("ModAction.count", 1) do
          post_auth bulk_media_regenerations_path, @admin, params: { search: { ai_tags_match: "filetype:png" }}
        end

        assert_redirected_to new_bulk_media_regeneration_path(search: { ai_tags_match: "filetype:png" })
        assert_enqueued_with(job: BulkMediaRegenerationJob, args: [{ query: "filetype:png" }])

        mod_action = ModAction.last
        assert_equal("media_asset_bulk_regenerate", mod_action.category)
        assert_equal(%{started a bulk regeneration of 1 media asset matching "filetype:png"}, mod_action.description)
        assert_nil(mod_action.subject)
        assert_equal(@admin, mod_action.creator)
      end

      should "not do anything if no query is given" do
        assert_no_difference("ModAction.count") do
          assert_no_enqueued_jobs(only: BulkMediaRegenerationJob) do
            post_auth bulk_media_regenerations_path, @admin
          end
        end

        assert_redirected_to new_bulk_media_regeneration_path
      end

      should "not allow non-admins to regenerate assets" do
        assert_no_difference("ModAction.count") do
          post_auth bulk_media_regenerations_path, create(:mod_user), params: { search: { ai_tags_match: "filetype:png" }}
        end

        assert_response 403
      end
    end
  end
end
