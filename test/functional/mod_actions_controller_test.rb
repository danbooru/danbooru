require 'test_helper'

class ModActionsControllerTest < ActionDispatch::IntegrationTest
  context "The mod actions controller" do
    context "index action" do
      setup do
        @ban = create(:mod_action, category: :post_ban)
        @unban = create(:mod_action, category: :post_unban)
      end

      should "work" do
        get mod_actions_path
        assert_response :success
      end

      context "category enum searches" do
        should respond_to_search(category: "post_ban").with { [@ban] }
        should respond_to_search(category: "post_unban").with { [@unban] }
        should respond_to_search(category: "Post_ban").with { [@ban] }
        should respond_to_search(category: "post_ban post_unban").with { [@unban, @ban] }
        should respond_to_search(category: "post_ban,post_unban").with { [@unban, @ban] }
        should respond_to_search(category: "44").with { [@ban] }
        should respond_to_search(category_id: "44").with { [@ban] }
        should respond_to_search(category_id: "44,45").with { [@unban, @ban] }
        should respond_to_search(category_id: ">=44").with { [@unban, @ban] }
      end
    end

    context "show action" do
      should "work" do
        @mod_action = create(:mod_action)
        get mod_action_path(@mod_action)
        assert_redirected_to mod_actions_path(search: { id: @mod_action.id })
      end
    end
  end
end
