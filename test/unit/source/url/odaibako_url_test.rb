require "test_helper"

module Source::Tests::URL
  class OdaibakoUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://ccs.odaibako.net/w=1600/post_images/aaaaaariko/c126b4961cea4a1c9ae016e224db2a62.jpeg.webp",
          "https://ccs.odaibako.net/w=1600/post_images/aaaaaariko/c126b4961cea4a1c9ae016e224db2a62.jpeg",
          "https://ccs.odaibako.net/_/post_images/aaaaaariko/c126b4961cea4a1c9ae016e224db2a62.jpeg",
        ],
        page_urls: [
          "https://odaibako.net/odais/d811a8ae-cc45-4922-9652-d2dcfb9d3492",
          "https://odaibako.net/posts/01923bc559bc0fd9ac983610d654ea2d",
        ],
        profile_urls: [
          "https://odaibako.net/u/aaaaaariko",
        ],
      )
    end
  end
end
