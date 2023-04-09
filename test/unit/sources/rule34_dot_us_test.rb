require "test_helper"

module Sources
  class Rule34DotUsTest < ActiveSupport::TestCase
    context "Rule34.us:" do
      context "A https://rule34.us/index.php?r=posts/view&id=$post_id URL" do
        strategy_should_work(
          "https://rule34.us/index.php?r=posts/view&id=6204967",
          page_url: "https://rule34.us/index.php?r=posts/view&id=6204967",
          image_urls: ["https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png"],
          tags: %w[sora kingdom_hearts rule_63 ai_generated brown_hair female genderswap_(mtf) nai_diffusion stable_diffusion],
          media_files: [{ file_size: 503_358 }],
        )
      end

      context "A https://rule34.us/hotlink.php?hash=$md5 URL" do
        strategy_should_work(
          "https://rule34.us/hotlink.php?hash=236690fd962fa394edf9894450261dac",
          page_url: "https://rule34.us/index.php?r=posts/view&id=6204967",
          image_urls: ["https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png"],
          tags: %w[sora kingdom_hearts rule_63 ai_generated brown_hair female genderswap_(mtf) nai_diffusion stable_diffusion],
          media_files: [{ file_size: 503_358 }],
        )
      end

      context "A https://rule34.us/images/xx/xx/$md5.png URL" do
        strategy_should_work(
          "https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png",
          page_url: "https://rule34.us/index.php?r=posts/view&id=6204967",
          image_urls: ["https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png"],
          tags: %w[sora kingdom_hearts rule_63 ai_generated brown_hair female genderswap_(mtf) nai_diffusion stable_diffusion],
          media_files: [{ file_size: 503_358 }],
        )
      end
    end
  end
end
