require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  context "The reports controller" do
    setup do
      @mod = create(:mod_user)
      @users = FactoryBot.create_list(:contributor_user, 2)
      @posts = @users.map do |u| 
        as(u) do
          create(:post)
        end
      end
    end

    context "uploads action" do
      should "render" do
        get_auth reports_uploads_path, @mod
        assert_response :success
      end
    end

    context "post_versions action" do
      should "render" do
        get_auth reports_post_versions_path, @mod
        assert_response :success
      end
    end
  end
end
