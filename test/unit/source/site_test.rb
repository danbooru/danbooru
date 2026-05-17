require "test_helper"

class SourceSiteTest < ActiveSupport::TestCase
  context "Source::Site" do
    should "find a site" do
      pixiv = Source::Site.find("Pixiv")

      assert_equal("Pixiv", pixiv.name)
      assert_equal("pixiv", pixiv.internal_name)
      assert_equal(11_197_707, pixiv.site_id)
      assert_equal("https://www.pixiv.net", pixiv.url.to_s)
      assert_includes(pixiv.domains, "pixiv.net")
      assert_includes(pixiv.domains, "pximg.net")
      assert_equal(Source::URL::Pixiv, pixiv.url_class)
      assert_includes(Source::Site.find_by_domain("pixiv.net"), pixiv)
    end

    should "have unique IDs for all sites" do
      sites = Source::Site.sites
      assert_equal(sites.size, sites.map(&:site_id).uniq.size)
    end
  end
end
