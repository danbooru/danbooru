require "test_helper"

module Source::Tests::URL
  class PlurkUrlTest < ActiveSupport::TestCase
    context "Plurk URLs" do
      should be_image_url(
        "https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg",
        "https://images.plurk.com/mx_5wj6WD0r6y4rLN0DL3sqag.jpg",
      )

      should be_page_url(
        "https://www.plurk.com/p/om6zv4",
        "https://www.plurk.com/m/p/okxzae",
        "https://www.plurk.com/s/p/3frqa0mcw9",
      )

      should be_profile_url(
        "https://www.plurk.com/m/redeyehare",
        "https://www.plurk.com/m/redeyehare/fans",
        "https://www.plurk.com/u/ddks2923",
        "https://www.plurk.com/m/u/leiy1225",
        "https://www.plurk.com/s/u/salmonroe13",
        "https://www.plurk.com/redeyehare",
        "https://www.plurk.com/redeyehare/fans",
      )

      should_not be_profile_url(
        "https://www.plurk.com/search?q=blah",
      )
    end
  end
end
