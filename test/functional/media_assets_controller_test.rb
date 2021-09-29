require 'test_helper'

class MediaAssetsControllerTest < ActionDispatch::IntegrationTest
  context "The media assets controller" do
    context "index action" do
      setup do
        @media_asset = create(:media_asset)
      end

      should "render" do
        get media_assets_path, as: :json

        assert_response :success
      end

      should respond_to_search({}).with { @media_asset }
      should respond_to_search(metadata: { "File:ColorComponents" => 3 }).with { @media_asset }
      should respond_to_search(metadata: { "File:ColorComponents" => 4 }).with { [] }
    end

    context "show action" do
      should "render" do
        @media_asset = create(:media_asset)
        get media_asset_path(@media_asset), as: :json

        assert_response :success
      end
    end
  end
end
