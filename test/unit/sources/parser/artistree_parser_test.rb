require "test_helper"

module Source::URL::Tests
  class ArtistreeParserTest < ActiveSupport::TestCase
    context "for image urls" do
      should_recognize_image_urls(
        "https://dwxo6p939as9l.cloudfront.net/seraexecfia/Anime Illustration/s6-s1lkmz.jpg",
        "https://dwxo6p939as9l.cloudfront.net/alysonsega/Full render (Character and/or Background/Object)/Sonicandmariotransparent-rkdqe1.png",
      )
    end

    context "for page urls" do
      should_recognize_page_urls(
        "https://artistree.io/crestfallen163",
        "https://artistree.io/crestfallen163#d2ca3306-0a5d-426e-925a-191593e6cfe1",
      )
    end

    context "for profile urls" do
      should_recognize_profile_urls(
        "https://artistree.io/crestfallen163",
        "https://artistree.io/request/adolfozapp",
        "https://artistree.io/queue/adolfozapp",
      )
    end

    context "when checking false positives" do
      should_not_find_false_positives(
        profile_urls: [
          "https://artistree.io/crestfallen163#d2ca3306-0a5d-426e-925a-191593e6cfe1",
        ],
      )
    end
  end
end
