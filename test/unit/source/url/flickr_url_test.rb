require "test_helper"

module Source::Tests::URL
  class FlickrUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        profile_urls: [
          "https://www.flickr.com/people/shirasaki408/",
          "https://www.flickr.com/photos/shirasaki408/49398982266/",
          "https://www.flickr.com/photos/hizna/sets/72157629448846789/",
        ],
      )
    end
  end
end
