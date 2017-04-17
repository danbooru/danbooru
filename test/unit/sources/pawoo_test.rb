require 'test_helper'

module Sources
  class PawooTest < ActiveSupport::TestCase
    context "The source site for pawoo" do
      setup do
        @site = Sources::Site.new("https://pawoo.net/web/statuses/1202176")
        @site.get
      end

      should "get the profile" do
        assert_equal("https://pawoo.net/@9ed00e924818", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("9ed00e924818", @site.artist_name)
      end

      should "get the image url" do
        assert_equal("https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png?1492461815", @site.image_url)
      end
    end
  end
end
