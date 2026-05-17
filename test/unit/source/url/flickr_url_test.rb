require "test_helper"

module Source::Tests::URL
  class FlickrUrlTest < ActiveSupport::TestCase
    context "Flickr URLs" do
      should be_profile_url(
        "https://www.flickr.com/people/shirasaki408/",
        "https://www.flickr.com/photos/shirasaki408/49398982266/",
        "https://www.flickr.com/photos/hizna/sets/72157629448846789/",
      )
    end

    should parse_url("https://www.flickr.com/people/shirasaki408/").into(site_name: "Flickr")
  end
end
