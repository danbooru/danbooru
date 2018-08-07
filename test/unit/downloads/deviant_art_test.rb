require 'test_helper'

module Downloads
  class DeviantArtTest < ActiveSupport::TestCase
    context "a download for a deviant art html page" do
      setup do
        skip "DeviantArt API keys not set" unless Danbooru.config.deviantart_client_id.present?
        
        @source = "http://starbitt.deviantart.com/art/09271X-636962118"
        @download = Downloads::File.new(@source)
        @tempfile, strategy = @download.download!
      end

      should "work" do
        assert_equal(2948, ::File.size(@tempfile.path))
      end
    end
  end
end
