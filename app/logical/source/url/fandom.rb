# frozen_string_literal: true

class Source::URL::Fandom < Source::URL
  WIKI_DB_NAMES = {
    "age-of-ishtaria": "ishtaria",
    "atelierseries": "atelier",
    "b-dapedia": "bdaman",
    "dragalialost_gamepedia_en": "dragalialost",
    "dungeon-ni-deai-o-motomeru": "danmachi",
    "gensin-impact": "genshin-impact",
    "guilty-gear": "guiltygear",
    "honkaiimpact3_gamepedia_en": "honkaiimpact3",
    "kagura": "senrankagura",
    "langrisser_gamepedia_en": "langrisser",
    "magic-school-lussid": "sid-story",
    "masterofeternity_gamepedia_en": "masterofeternity",
    "rockman_x_dive": "rockman-x-dive",
    "strikewitches": "worldwitches",
    "sword-art-online": "swordartonline",
    "talesofseries-the-tales-of": "tales-of",
    "to-aru-majutsu-no-index": "toarumajutsunoindex",
  }.with_indifferent_access

  attr_reader :wiki_db_name, :file, :page_url, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[nocookie.net fandom.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://vignette.wikia.nocookie.net/queensblade/images/3/33/WGAIRI1.jpg/
    # https://vignette1.wikia.nocookie.net/valkyriecrusade/images/b/bf/Joan_Of_Arc_H.png/revision/latest?cb=20170801081004
    # https://static.wikia.nocookie.net/valkyriecrusade/images/3/3f/Joan_Of_Arc.png/revision/latest/scale-to-width-down/270?cb=20170801081000
    in _, "nocookie.net", wiki_db_name, "images", /^\h$/ => subdir1, /^\h\h$/ => subdir2, file, *rest
      @wiki_db_name = wiki_db_name
      @file = file
      @full_image_url = "https://static.wikia.nocookie.net/#{wiki_db_name}/images/#{subdir1}/#{subdir2}/#{file}"
      @page_url = "https://#{wiki}.fandom.com/wiki/Gallery?file=#{file}"

    else
      nil
    end
  end

  def wiki
    WIKI_DB_NAMES.fetch(wiki_db_name, wiki_db_name)
  end
end
