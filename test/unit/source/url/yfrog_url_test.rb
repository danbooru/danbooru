require "test_helper"

module Source::Tests::URL
  class YfrogUrlTest < ActiveSupport::TestCase
    context "Yfrog URLs" do
      should parse_url("http://yfrog.com/gyi1smoj").into(
        page_url: "http://yfrog.com/gyi1smoj",
      )

      should parse_url("http://twitter.yfrog.com/z/oe3umiifj").into(
        page_url: "http://yfrog.com/oe3umiifj",
      )

      should parse_url("http://yfrog.com/user/0128sinonome/photos").into(
        profile_url: "http://yfrog.com/user/0128sinonome/photos",
      )
    end
  end
end
