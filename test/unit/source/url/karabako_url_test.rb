require "test_helper"

module Source::Tests::URL
  class KarabakoUrlTest < ActiveSupport::TestCase
    context "Karabako URLs" do
      should parse_url("http://www.karabako.net/images/karabako_38835.jpg").into(
        page_url: "http://www.karabako.net/post/view/38835",
      )
    end

    should parse_url("http://www.karabako.net/images/karabako_38835.jpg").into(site_name: "Karabako")
  end
end
