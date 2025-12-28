require "test_helper"

module Source::Tests::URL
  class PoipikuUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://cdn.poipiku.com/009416896/010718302_023702506_X5LNftu5w.jpeg?Expires=XXX&Signature=XXX&Key-Pair-Id=XXX",
          "https://cdn.poipiku.com/009416896/010718302_023702506_X5LNftu5w.jpeg_640.jpg",
          "https://cdn.poipiku.com/009416896/010718302_W0EFku4aW.jpeg?Expires=XXX&Signature=XXX&Key-Pair-Id=XXX",
          "https://cdn.poipiku.com/009416896/010718302_W0EFku4aW.jpeg_640.jpg",
          "https://cdn.poipiku.com/000003310/000007036.jpeg?Expires=XXX&Signature=XXX&Key-Pair-Id=XXX",
          "https://img.poipiku.com/user_img02/006849873/008271386_016865825_S968sAh7Y.jpeg_640.jpg",
          "https://img.poipiku.com/user_img03/000020566/007185704_nb1cTuA1I.jpeg_640.jpg ",
          "https://img.poipiku.com/user_img02/000003310/000007036.jpeg_640.jpg ",
          "https://img-org.poipiku.com/user_img02/006849873/008271386_016865825_S968sAh7Y.jpeg",
          "https://img-org.poipiku.com/user_img03/000020566/007185704_nb1cTuA1I.jpeg ",
          "https://img-org.poipiku.com/user_img02/000003310/000007036.jpeg ",
        ],
        page_urls: [
          "https://poipiku.com/6849873/8271386.html",
        ],
        profile_urls: [
          "https://poipiku.com/IllustListPcV.jsp?ID=9056",
          "https://poipiku.com/IllustListGridPcV.jsp?ID=9056",
          "https://poipiku.com/6849873",
        ],
      )
    end
  end
end
