require 'test_helper'

class TagVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The tag versions controller" do
    context "index action" do
      setup do
        @user = create(:user)
        @tag = create(:tag, name: "test", created_at: 6.months.ago, updated_at: 3.months.ago)
        travel_to(4.hours.ago) { @tag.update!(category: Tag.categories.character, updater: @user) }
        travel_to(3.hours.ago) { @tag.update!(is_deprecated: true, updater: @user) }
        travel_to(2.hours.ago) { @tag.update!(is_deprecated: false, updater: @user) }
      end

      should "render" do
        get tag_versions_path
        assert_response :success
      end

      should "render for a tag" do
        get tag_versions_path(search: { name_matches: @tag.name })
        assert_response :success
      end

      should "render for a user" do
        get tag_versions_path(search: { updater_id: @user.id })
        assert_response :success
      end

      should "render for a json response" do
        get tag_versions_path, as: :json
        assert_response :success
      end
    end

    context "show action" do
      setup do
        @user = create(:user)
        @tag = create(:tag)
        @tag.update!(category: Tag.categories.character, updater: @user)
      end

      should "render" do
        get tag_version_path(@tag.versions.last)
        assert_redirected_to tag_versions_path(search: { id: @tag.versions.last.id })
      end

      should "render for a json response" do
        get tag_version_path(@tag.versions.last), as: :json
        assert_response :success
      end
    end
  end
end
