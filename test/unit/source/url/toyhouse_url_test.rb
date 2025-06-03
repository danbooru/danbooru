require "test_helper"

module Source::Tests::URL
  class ToyhouseUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://f2.toyhou.se/file/f2-toyhou-se/thumbnails/58037599_Ov5.png",
          "https://f2.toyhou.se/file/f2-toyhou-se/images/58037599_Ov5j4w66lQRw9G4.png",
          "https://f2.toyhou.se/file/f2-toyhou-se/watermarks/73741617_fFIUcJscE.png",
          "https://f2.toyhou.se/file/f2-toyhou-se/characters/19108771?1670101610",
          "https://file.toyhou.se/images/2362055_rxkHiEqZOFFaOtX.png",
          "https://file.toyhou.se/characters/654769?1480733146",
        ],
        page_urls: [
          "https://toyhou.se/~images/58037599",
          "https://toyhou.se/2712983.cudlil/19136842.reference-sheet/73741617",
          "https://toyhou.se/2712983.cudlil/19136842.reference-sheet#73741617",
          "https://toyhou.se/2712983.cudlil/19136842.reference-sheet",
          "https://toyhou.se/19108771.june-human-/58037599",
          "https://toyhou.se/19108771.june-human-#58037599",
          "https://toyhou.se/19108771.june-human-/gallery",
          "https://toyhou.se/19108771.june-human-",
          "https://toyhou.se/427Deer#55232380",
        ],
        profile_urls: [
          "https://toyhou.se/427Deer",
          "https://toyhou.se/427Deer/characters",
          "https://toyhou.se/lilcudds/characters/folder:539748",
        ],
        bad_sources: [
          "https://toyhou.se/2712983.cudlil/19136842.reference-sheet",
          "https://toyhou.se/19108771.june-human-/gallery",
          "https://toyhou.se/19108771.june-human-",
          "https://toyhou.se/427Deer",
        ],
      )
    end
  end
end
