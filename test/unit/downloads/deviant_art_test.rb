require 'test_helper'

module Downloads
  class DeviantArtTest < ActiveSupport::TestCase
    context "a download for a deviant art html page" do
      setup do
        skip "DeviantArt API keys not set" unless Danbooru.config.deviantart_client_id.present?
        
        @source = "https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484"
        @download = Downloads::File.new(@source)
        @tempfile, strategy = @download.download!
      end

      should "work" do
        assert_equal(877987, ::File.size(@tempfile.path))
      end
    end
  end
end
