require 'test_helper'

class ModActionsControllerTest < ActionDispatch::IntegrationTest
  context "The mod actions controller" do
    setup do
      @mod_action = create(:mod_action)
    end

    context "index action" do
      should "work" do
        get mod_actions_path
        assert_response :success
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
