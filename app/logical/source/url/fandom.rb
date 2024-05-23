# frozen_string_literal: true

class Source::URL::Fandom < Source::URL
  # Matches language codes like 'ja' or 'pt-br'
  LANG_CODE_REGEX = /^[a-z]{2,3}(-[a-z]{2,3})?$/

  RESERVED_WIKI_NAMES = [nil, "auth", "www"]

  WIKI_NAMES = {
    # [Lang, Database name] => Wiki name
    [nil,  "adventuretimewithfinnandjake"] =>   "adventuretime",
    [nil,  "age-of-ishtaria"] =>                "ishtaria",
    [nil,  "atelierseries"] =>                  "atelier",
    [nil,  "b-dapedia"] =>                      "bdaman",
    [nil,  "blackbullet2"] =>                   "blackbullet",
    [nil,  "blacksurvival_gamepedia_en"] =>     "blacksurvival",
    [nil,  "capcomdatabase"] =>                 "capcom",
    [nil,  "dragalialost_gamepedia_en"] =>      "dragalialost",
    [nil,  "dragonauttheresonance"] =>          "dragonaut",
    [nil,  "dungeon-ni-deai-o-motomeru"] =>     "danmachi",
    [nil,  "dynastywarriors"] =>                "koei",
    [nil,  "fault-milestone8968"] =>            "fault-series",
    [nil,  "genjitsushugisha"] =>               "genkoku",
    [nil,  "gen-impact"] =>                     "genshin-impact",
    [nil,  "gensin-impact"] =>                  "genshin-impact",
    [nil,  "grimm-notes-jp"] =>                 "grimms-notes-jp",
    [nil,  "guilty-gear"] =>                    "guiltygear",
    [nil,  "harvestmoonrunefactory"] =>         "therunefactory",
    [nil,  "honkaiimpact3_gamepedia_en"] =>     "honkaiimpact3",
    [nil,  "isekai-maou-to-shoukan-shoujo-dorei-majutstu"] => "isekai-maou",
    [nil,  "kagura"] =>                         "senrankagura",
    [nil,  "langrisser_gamepedia_en"] =>        "langrisser",
    [nil,  "littlewitch"] =>                    "little-witch-academia",
    [nil,  "madannooutovanadis"] =>             "madan",
    [nil,  "magiarecord-en"] =>                 "magireco",
    [nil,  "magic-school-lussid"] =>            "sid-story",
    [nil,  "mahousenseinegima"] =>              "negima",
    [nil,  "masterofeternity_gamepedia_en"] =>  "masterofeternity",
    [nil,  "ninehourspersonsdoors"] =>          "zeroescape",
    [nil,  "onigiri-en"] =>                     "onigiri",
    [nil,  "p__"] =>                            "hero",
    [nil,  "ritualofthenight"] =>               "bloodstained",
    [nil,  "rockman_x_dive"] =>                 "rockman-x-dive",
    [nil,  "romancingsaga"] =>                  "saga",
    [nil,  "shirocolle"] =>                     "shiropro",
    [nil,  "silent"] =>                         "silenthill",
    [nil,  "strikewitches"] =>                  "worldwitches",
    [nil,  "sword-art-online"] =>               "swordartonline",
    ["ru", "sword-art-online"] =>               "sword-art-online",
    ["es", "sao"] =>                            "swordartonline",
    [nil,  "senkizesshousymphogear"] =>         "symphogear",
    [nil,  "talesofseries-the-tales-of"] =>     "tales-of",
    [nil,  "tensei-shitara-slime-datta-ken"] => "tensura",
    [nil,  "the-dreath-mage-who-doesnt-want-a-fourth-time"] => "death-mage",
    [nil,  "to-aru-majutsu-no-index"] =>        "toarumajutsunoindex",
    [nil,  "utawareru"] =>                      "utawarerumono",
    [nil,  "yorukuni"] =>                       "nightsofazure",
    [nil,  "youkoso-jitsuryoku-shijou-shugi-no-kyoushitsu-e"] => "you-zitsu",
    [nil,  "zoe"] =>                            "zoneoftheenders",
  }.with_indifferent_access

  attr_reader :wiki_db_name, :file, :path_prefix, :image_uuid, :full_image_path, :page

  def self.match?(url)
    url.domain.in?(%w[nocookie.net fandom.com wikia.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81/thumbnail/width/400/height/400 (user profile picture)
    # https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81?format=original (full)
    in _, "nocookie.net", /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/ => image_uuid, *rest
      @image_uuid = image_uuid

    # https://static.wikia.nocookie.net/queensblade/images/3/33/WGAIRI1.jpg
    in _, "nocookie.net", *rest
      parse_path

    in wiki, "fandom.com", *segments unless wiki.in?(RESERVED_WIKI_NAMES)
      @wiki = wiki

      # https://genshin-impact.fandom.com/pt-br/f
      # https://genshin-impact.fandom.com/ja/wiki/凝光/ギャラリー
      @path_prefix = segments.shift if segments.first&.match?(LANG_CODE_REGEX)

      # https://typemoon.fandom.com/f/p/4400000000000077950
      return if segments.first == "f"

      # https://typemoon.fandom.com/wiki/Tamamo-no-Mae
      segments.shift if segments.first == "wiki"

      # https://typemoon.fandom.com/Tamamo-no-Mae?file=Caster_Extra_Takeuchi_design_1.png
      # https://typemoon.fandom.com/User:Lemostr00
      # https://typemoon.fandom.com/File:Memories_of_Trifas.png
      # https://genshin-impact.fandom.com/Ningguang/Gallery
      # https://genshin-impact.fandom.com/ja/凝光/ギャラリー
      @page = segments.join("/")
      @file = @page.starts_with?("File:") ? @page.delete_prefix("File:") : params[:file]

    # http://images3.wikia.nocookie.net/fireemblem/images/archive/2/2b/20080623085034%21Dorothy.JPG
    else
      nil
    end
  end

  def parse_path
    segments = path_segments.dup
    segments.shift if path_segments.first in /^__cb\d+$/

    case segments
    # https://vignette.wikia.nocookie.net/p__/images/3/3f/Yukiko_Amagi_%28BlazBlue_Cross_Tag_Battle%2C_Character_Select_Artwork%29.png/revision/latest?cb=20171119153335&path-prefix=protagonist (.webp sample)
    # https://static.wikia.nocookie.net/valkyriecrusade/images/3/3f/Joan_Of_Arc.png/revision/latest/scale-to-width-down/270?cb=20170801081000 (.webp sample)
    # https://img3.wikia.nocookie.net/__cb20140404214519/typemoon/images/f/fd/Aozaki_Aoko_Blue.png/revision/latest?path-prefix=fr (.webp sample)
    # https://img3.wikia.nocookie.net/__cb20130523100711/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png (.webp sample)
    # https://img3.wikia.nocookie.net/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png (.webp sample)
    in wiki_db_name, "images", /^\h$/, /^\h\h$/, file, *rest
      @wiki_db_name = wiki_db_name
      @path_prefix = params["path-prefix"]
      @file = file

    # http://images1.wikia.nocookie.net/__cb20121102042049/disgaea/en/images/1/15/DD2_Publicity_02.jpg (.webp sample)
    # https://vignette.wikia.nocookie.net/p__/protagonist/images/3/3f/Yukiko_Amagi_(BlazBlue_Cross_Tag_Battle%2C_Character_Select_Artwork).png
    # https://static.wikia.nocookie.net/typemoon/fr/images/f/fd/Aozaki_Aoko_Blue.png
    in wiki_db_name, path_prefix, "images", /^\h$/, /^\h\h$/, file, *rest
      @wiki_db_name = wiki_db_name
      @path_prefix = path_prefix
      @file = file

    # http://img3.wikia.nocookie.net/__cb20130520180921/allanimefanon/images/thumb/8/82/2560-1600-104761.jpg/2000px-2560-1600-104761.jpg
    # http://img3.wikia.nocookie.net/allanimefanon/images/thumb/8/82/2560-1600-104761.jpg/2000px-2560-1600-104761.jpg
    in wiki_db_name, "images", "thumb", /^\h$/, /^\h\h$/, file, *rest
      @wiki_db_name = wiki_db_name
      @path_prefix = params[:path_prefix]
      @file = file

    # https://img3.wikia.nocookie.net/__cb20140404214519/typemoon/fr/images/thumb/f/fd/Aozaki_Aoko_Blue.png/500px-Aozaki_Aoko_Blue.png
    # https://img3.wikia.nocookie.net/typemoon/fr/images/thumb/f/fd/Aozaki_Aoko_Blue.png/500px-Aozaki_Aoko_Blue.png
    in wiki_db_name, path_prefix, "images", "thumb", /^\h$/, /^\h\h$/, file, *rest
      @wiki_db_name = wiki_db_name
      @path_prefix = path_prefix
      @file = file

    else
      nil
    end
  end

  def image_url?
    domain == "nocookie.net"
  end

  def bad_source?
    !image_url? && file.blank?
  end

  def full_image_url
    if wiki_db_name.present? && file.present?
      subdir = Digest::MD5.hexdigest(file)
      full_image_path = [wiki_db_name, path_prefix, "images", subdir[0], subdir[0..1], file].compact.join("/")
      URI.join("https://static.wikia.nocookie.net", full_image_path, "?format=original").to_s
    elsif image_uuid.present?
      "https://static.wikia.nocookie.net/#{image_uuid}?format=original"
    end
  end

  def page_url
    if profile_url.present? && page.present? && file.present? && !page.starts_with?("File:")
      "#{profile_url}/wiki/#{page}?file=#{Danbooru::URL.escape(file)}"
    elsif profile_url.present? && file.present?
      "#{profile_url}/wiki/File:#{Danbooru::URL.escape(file)}"
    elsif profile_url.present? && page.present?
      "#{profile_url}/wiki/#{page}"
    end
  end

  def profile_url
    if wiki.present? && lang.present?
      "https://#{wiki}.fandom.com/#{lang}"
    elsif wiki.present?
      "https://#{wiki}.fandom.com"
    end
  end

  def lang
    path_prefix unless path_prefix == "en" || !path_prefix&.match?(LANG_CODE_REGEX)
  end

  def wiki
    @wiki || WIKI_NAMES[[lang, wiki_db_name]] || wiki_db_name
  end
end
