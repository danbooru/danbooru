require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  context "The reports controller" do
    setup do
      @mod = create(:mod_user)
      @users = FactoryBot.create_list(:contributor_user, 2)
      @posts = @users.map do |u|
        create(:post, uploader: u)
      end
    end

    context "uploads action" do
      should "render" do
        get_auth reports_uploads_path, @mod
        assert_response :success
      end
    end

    context "upload_tags action" do
      should "render" do
        get reports_upload_tags_path(user_id: @users.first)
        assert_response :success
      end
    end
  end
end
