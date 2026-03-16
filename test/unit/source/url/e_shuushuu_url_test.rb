require "test_helper"

module Source::Tests::URL
  class EShuushuuUrlTest < ActiveSupport::TestCase
    context "E-Shuushuu URLs" do
      should parse_url("http://e-shuushuu.net/images/2014-07-22-662472.png").into(
        page_url: "https://e-shuushuu.net/image/662472",
      )
    end

    should parse_url("http://e-shuushuu.net/images/2014-07-22-662472.png").into(site_name: "E-Shuushuu")
  end
end
