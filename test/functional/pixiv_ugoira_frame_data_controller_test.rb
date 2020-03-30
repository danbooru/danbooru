require "test_helper"

class PixivUgoiraFrameDataControllerTest < ActionDispatch::IntegrationTest
  context "index action" do
    should "work" do
      create(:pixiv_ugoira_frame_data)
      get pixiv_ugoira_frame_data_path, as: :json
      assert_response :success
    end
  end
end
