require 'test_helper'

class PostApprovalsControllerTest < ActionDispatch::IntegrationTest
  context "The post approvals controller" do
    setup do
      @approval = FactoryBot.create(:post_approval)
    end

    context "index action" do
      should "render" do
        get post_approvals_path
        assert_response :success
      end
    end
  end
end
