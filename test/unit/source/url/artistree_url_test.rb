require "test_helper"

module Source::Tests::URL
  class ArtistreeUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://dwxo6p939as9l.cloudfront.net/seraexecfia/Anime Illustration/s6-s1lkmz.jpg",
          "https://dwxo6p939as9l.cloudfront.net/alysonsega/Full render (Character and/or Background/Object)/Sonicandmariotransparent-rkdqe1.png",
        ],
        profile_urls: [
          "https://artistree.io/crestfallen163",
          "https://artistree.io/request/adolfozapp",
          "https://artistree.io/queue/adolfozapp",
        ],
        page_urls: [
          "https://artistree.io/crestfallen163",
          "https://artistree.io/crestfallen163#d2ca3306-0a5d-426e-925a-191593e6cfe1",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://artistree.io/crestfallen163#d2ca3306-0a5d-426e-925a-191593e6cfe1",
        ],
      )
    end
  end
end
