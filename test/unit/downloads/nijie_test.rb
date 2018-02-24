require "test_helper"

module Downloads
  class NijieTest < ActiveSupport::TestCase
    context "downloading a 'http://nijie.info/view.php?id=:id' url" do
      should "download the original file" do
        @source = "http://nijie.info/view.php?id=213043"
        @rewrite = "https://pic03.nijie.info/nijie_picture/728995_20170505014820_0.jpg"
        assert_rewritten(@rewrite, @source)
        assert_downloaded(132_555, @source)
      end
    end

    context "downloading a 'https://pic*.nijie.info/nijie_picture/:id.jpg' url" do
      should "download the original file" do
        @source = "https://pic03.nijie.info/nijie_picture/728995_20170505014820_0.jpg"
        assert_not_rewritten(@source)
        assert_downloaded(132_555, @source)
      end
    end
  end
end
