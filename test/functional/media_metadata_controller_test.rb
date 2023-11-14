require 'test_helper'

class MediaMetadataControllerTest < ActionDispatch::IntegrationTest
  context "The media metadata controller" do
    context "index action" do
      should "render" do
        create(:media_metadata)
        get media_metadata_path, as: :json

        assert_response :success
      end

      should "work with the only=media_asset param" do
        metadata = create(:media_metadata)
        get media_metadata_path(only: "media_asset"), as: :json

        assert_response :success
        assert_equal(metadata.media_asset.id, response.parsed_body.sole.dig("media_asset", "id"))
      end

      context "searching" do
        setup do
          @jpg = create(:media_metadata, file: "test/files/test.jpg")
          @gif = create(:media_metadata, file: "test/files/test.gif")
          @png = create(:media_metadata, file: "test/files/test.png")
        end

        should respond_to_search(has_metadata: true).with { [@png, @gif, @jpg] }

        should respond_to_search(metadata_has_key: "File:ColorComponents").with { [@jpg] }
        should respond_to_search(metadata: { "File:ColorComponents": 3 }).with { [@jpg] }
        should respond_to_search(metadata: { "File:ColorComponents": "3" }).with { [@jpg] }

        should respond_to_search(metadata_has_key: "GIF:GIFVersion").with { [@gif] }
        should respond_to_search(metadata: { "GIF:GIFVersion": "89a" }).with { [@gif] }

        should respond_to_search(metadata_has_key: "PNG:ColorType").with { [@png] }
        should respond_to_search(metadata: { "PNG:ColorType": "RGB" }).with { [@png] }
      end
    end
  end
end
