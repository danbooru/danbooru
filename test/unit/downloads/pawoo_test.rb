require "test_helper"

module Downloads
  class PawooTest < ActiveSupport::TestCase
    context "downloading a 'https://pawoo.net/web/statuses/:id' url" do
      should "download the original file" do
        @source = "https://pawoo.net/web/statuses/1202176"
        @rewrite = "https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(7680, @source)
      end
    end

    context "downloading a 'https://pawoo.net/:user/:id' url" do
      should "download the original file" do
        @source = "https://pawoo.net/@9ed00e924818/1202176"
        @rewrite = "https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(7680, @source)
      end
    end

    context "downloading a 'https://img.pawoo.net/media_attachments/:id/small/:file' url" do
      should "download the original file" do
        @source = "https://img.pawoo.net/media_attachments/files/000/128/953/small/4c0a06087b03343f.png"
        @rewrite = "https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(7680, @source)
      end
    end
  end
end
