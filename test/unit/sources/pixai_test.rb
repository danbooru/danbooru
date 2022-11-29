require "test_helper"

module Sources
  class PixaiTest < ActiveSupport::TestCase
    context "A Pixai source extractor" do
      context "A Pixai direct image url" do
        strategy_should_work(
          "https://imagedelivery.net/5ejkUOtsMH5sf63fw6q33Q/7b3af338-b087-400d-ede6-74bc5c63a500/public",
          image_urls: ["https://imagedelivery.net/5ejkUOtsMH5sf63fw6q33Q/7b3af338-b087-400d-ede6-74bc5c63a500/public"],
          page_url: nil,
          download_size: 593_220,
        )
      end

      context "A Pixai thumbnail url" do
        strategy_should_work(
          "https://imagedelivery.net/5ejkUOtsMH5sf63fw6q33Q/7b3af338-b087-400d-ede6-74bc5c63a500/thumbnail",
          image_urls: ["https://imagedelivery.net/5ejkUOtsMH5sf63fw6q33Q/7b3af338-b087-400d-ede6-74bc5c63a500/public"],
          page_url: nil,
          download_size: 593_220,
        )
      end

      context "A Pixai post url" do
        strategy_should_work(
          "https://pixai.art/artwork/1553702952389647410",
          image_urls: ["https://imagedelivery.net/5ejkUOtsMH5sf63fw6q33Q/ace59f44-0f29-47c9-855d-516edb5bcc00/public"],
          page_url: "https://pixai.art/artwork/1553702952389647410",
          artist_commentary_title: "And another! (Credit to Hálainnithomiinae for the prompt template here)",
          download_size: 460_190,
        )
      end
    end
  end
end
