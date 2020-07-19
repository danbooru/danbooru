require 'test_helper'

class ModActionsControllerTest < ActionDispatch::IntegrationTest
  context "The mod actions controller" do
    setup do
      @mod_action = create(:mod_action, description: "blah", category: "post_delete")
    end

    context "index action" do
      setup do
        @promote_action = create(:mod_action, category: "user_level_change", creator: build(:builder_user, name: "rumia"))
        @unrelated_action = create(:mod_action)
      end

      should "render" do
        get mod_actions_path
        assert_response :success
      end

      should respond_to_search({}).with { [@unrelated_action, @promote_action, @mod_action] }
      should respond_to_search(category: ModAction.categories["user_level_change"]).with { @promote_action }
      should respond_to_search(description_matches: "blah").with { @mod_action }

      context "using includes" do
        should respond_to_search(creator_name: "rumia").with { @promote_action }
        should respond_to_search(creator: {level: User::Levels::BUILDER}).with { @promote_action }
      end
    end

    context "show action" do
      should "work" do
        get mod_action_path(@mod_action)
        assert_redirected_to mod_actions_path(search: { id: @mod_action.id })
      end
    end
  end
end
