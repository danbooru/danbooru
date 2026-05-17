# frozen_string_literal: true

class Source::URL::Null < Source::URL
  site "Null"

  attr_reader :work_id, :page_url, :profile_url

  def self.match?(_url)
    true
  end

  def site_name
    case [subdomain, domain]
    in "myship", "7-11.com.tw"
      "7-Eleven MyShip"
    in _, ("aminoapps.com" | "narvii.com")
      "Amino"
    in _, "anilist.co"
      "AniList"
    in "music", "apple.com"
      "Apple Music"
    in _, "archiveofourown.org"
      "Archive of Our Own"
    in _, "artfight.net"
      "Art Fight"
    in _, "artistsnclients.com"
      "Artists&Clients"
    in _, "gamer.com.tw"
      "Bahamut"
    in _, ("bandcamp.com" | "bcbits.com")
      "Bandcamp"
    in _, "theshop.jp" | "thebase.com"
      "BASE"
    in _, "bigcartel.com"
      "Big Cartel"
    in _, "booru.org"
      "Booru.org"
    in _, "buymeacoffee.com"
      "Buy Me a Coffee"
    in _, "cash.app"
      "Cash App"
    in _, "circle.ms"
      "Circle.ms"
    in _, ("class101.co" | "class101.net")
      "Class101"
    in _, "cli-bo.com" | "clibo.tw"
      "Clibo"
    in _, "colorslive.com"
      "Colors Live"
    in "comicvine", "gamespot.com"
      "Comic Vine"
    in _, "commiss.io"
      "Commiss.io"
    # XXX curiouscat.qa is possibly a different site
    # https://www.bleepingcomputer.com/news/security/popular-qanda-app-curious-cat-loses-domain-posts-bizarre-tweets/
    in _, ("curiouscat.live" | "curiouscat.me" | "curiouscat.qa")
      "Curious Cat"
    in _, "direct.me"
      "Direct.me"
    in _, "doujinshi.org"
      "Doujinshi.org"
    in "doujinshi", "mugimugi.org"
      "Doujinshi.org"
    in _, "cloudfront.net" if host == "dxthpu4318olx.cloudfront.net"
      "Drawcrowd"
    in _, "eth.co"
      "Eth.co"
    in _, "exblog.jp"
      "Excite Blog"
    in _, "fanfiction.net"
      "FanFiction.Net"
    in _, "finalfantasyxiv.com"
      "Final Fantasy XIV"
    in "gamefaqs", "gamespot.com"
      "GameFAQs"
    in _, "ganknow.com"
      "Gank"
    in _, ("github.com" | "githubassets.com")
      "GitHub"
    in _, "gumpla.jp"
      "Gunsta"
    in _, "hatena.ne.jp"
      "Hatena"
    in _, ("hatenablog.com" | "hatenablog.jp" | "hateblo.jp" | "st-hatena.com")
      "Hatena Blog"
    in _, "html.co.jp"
      "html.co.jp"
    in _, "imagecomics.com"
      "Image Comics"
    in _, "img.ly"
      "img.ly"
    in _, "instabio.cc" | "linkbio.co"
      "Instabio"
    in _, "itch.io"
      "Itch.io"
    in _, "lava.top"
      "Lava.top"
    in _, "leagueofcomicgeeks.com"
      "League of Comic Geeks"
    in _, ("line.me" | "line-apps.com")
      "Line"
    in _, ("linkedin.com" | "licdn.com")
      "LinkedIn"
    in _, "livedoor.jp"
      "Livedoor"
    in "livedoor", "blogimg.jp"
      "Livedoor"
    in _, ("2chblog.jp" | "blog.jp" | "bloggeek.jp" | "blogism.jp" | "blogo.jp" | "blogstation.jp" | "blogto.jp" | "cafeblog.jp" | "corpblog.jp" | "diary.to" | "doorblog.jp" | "dreamlog.jp" | "gger.jp" | "golog.jp" | "ldblog.jp" | "liblo.jp" | "livedoor.biz" | "myjournal.jp" | "mynikki.jp" | "officeblog.jp" | "officialblog.jp" | "publog.jp" | "storeblog.jp" | "teamblog.jp" | "techblog.jp" | "weblog.to" | "xxxblog.jp" | "youblog.jp")
      "Livedoor"
    in _, "lit.link"
      "Lit.link"
    in _, ("kirbyscomicart.com" | "kirbyscomicartshop.com")
      "Kirby's Comic Art"
    in _, "kirumade.com"
      "Kiru Made"
    in _, "kemono.party"
      "Kemono Party"
    in _, "last.fm"
      "Last.fm"
    in _, "mangaz.com"
      "Manga Library Z"
    in _, "manga-no.com"
      "Mangano"
    in _, "marpple.shop"
      "MarppleShop"
    in _, ("mastodon.cloud" | "mstdn.jp")
      "Mastodon"
    in _, "msha.ke" | "milkshake.app"
      "Milkshake"
    in _, "myanimelist.net"
      "MyAnimeList"
    in _, "myfigurecollection.net"
      "MyFigureCollection"
    in _, "mixi.jp"
      "Mixi.jp"
    in _, "ocn.ne.jp"
      "OCN"
    in _, "onlyfans.com"
      "OnlyFans"
    in _, "ouxiangxiezhen.com"
      "Ou Xiang Xie Zhen"
    in _, ("overdoll.com" | "dollycdn.net")
      "Overdoll"
    in _, ("paypal.com" | "paypal.me" | "paypalobjects.com")
      "PayPal"
    in _, "pixeljoint.com"
      "Pixel Joint"
    in _, "planetminecraft.com"
      "Planet Minecraft"
    in _, "pronouns.page"
      "Pronouns.page"
    in _, "pronouny.xyz"
      "Pronouny.xyz"
    in _, ("joyreactor.cc" | "reactor.cc")
      "Joyreactor"
    in "rookie", "shonenjump.com"
      "Jump Rookie!"
    in _, "sakura.ne.jp"
      "Sakura.ne.jp"
    in "scratch", "mit.edu"
      "Scratch"
    in "drawme", "share-on.me"
      "Secret Drawing Box"
    in _, "sheezy.art"
      "Sheezy.art"
    in _, "solo.to"
      "Solo.to"
    in _, ("soundcloud.com" | "sndcdn.com")
      "SoundCloud"
    in _, "smutba.se"
      "SmutBase"
    in _, ("spotify.com" | "spotifycdn.com")
      "Spotify"
    in _, "square.site" | "squareup.com"
      "Square"
    in _, ("steamstatic.com" | "steamcommunity.com")
      "Steam"
    in _, "straw.page"
      "Straw.page"
    in _, ("strikingly.com" | "mystrikingly.com")
      "Strikingly"
    in _, ("subscribestar.adult" | "subscribestar.com")
      "SubscribeStar"
    in _, "superrare.com"
      "SuperRare"
    in _, "suzuri.jp"
      "Suzuri"
    in _, "cloudfront.net" if host == "dijsur42hqnz1.cloudfront.net"
      "Suzuri"
    in _, "doujin.com.tw"
      "Taiwan Doujinshi Center"
    in _, "tapas.io"
      "Tapas"
    in _, "cloudfront.net" if host == "d30womf5coomej.cloudfront.net"
      "Tapas"
    in _, "teepublic.com"
      "TeePublic"
    in _, ("pipa.jp" | "tegaki.com")
      "Tegaki"
    in _, ("telegram.org" | "t.me")
      "Telegram"
    in _, "tensor.art"
      "TensorArt"
    in _, "theinterviews.jp"
      "The Interviews"
    in _, "tistory.com"
      "Tistory"
    in "t1", "daumcdn.net"
      "Tistory"
    in "bxp-content-static.prod.public", "atl-paas.net"
      "Trello"
    in _, "tsunagu.cloud"
      "tsunagu.cloud"
    in _, ("vimeo.com" | "vimeocdn.com" | "livestream.com")
      "Vimeo"
    in _, "webtoons.com"
      "Webtoons"
    in "webtoons-static"
      "Webtoons"
    in _, ("weebly.com" | "weeblysite.com")
      "Weebly"
    in _, "wlo.link"
      "Willow"
    in _, ("wix.com" | "wixsite.com" | "wixstatic.com")
      "Wix"
    in _, ("wordpress.com" | "wp.com")
      "WordPress"
    in _, "ych.art"
      "YCH.art"
    in _, nil
      # "http://125.6.189.215/kcs2/resources/ship/full/0935_5098_aeltexuflkxs.png?version=52" => "125.6.189.215"
      authority
    else
      # "www.melonbooks.co.jp" => "Melonbooks"
      parsed_domain.sld.titleize
    end
  end

  def parse
    @recognized = true

    case [subdomain, domain, *path_segments]

    # http://img.booru.org/drawfriends//images/36/de65da5f588b76bc1d9de8af976b540e2dff17e2.jpg
    in _, "booru.org", *rest
      nil

    # https://shop.comiczin.jp/products/list.php?category_id=3394
    in _, "comiczin.jp", *rest
      nil

    # https://curiouscat.me/azurane
    in _, "curiouscat.me", *rest
      nil

    # https://crepu.net/user/Mizunouchilucia
    in _, "crepu.net", *rest
      nil

    # https://derpibooru.org/tags/artist-colon-checkerboardazn
    in _, "derpibooru.org", *rest
      nil

    # http://www.doujinshi.org/browse/circle/65368/
    # http://www.doujinshi.org/browse/author/979/23/
    in _, "doujinshi.org", *rest
      nil

    # http://doujinshi.mugimugi.org/browse/author/3029/
    # http://doujinshi.mugimugi.org/browse/circle/7210/
    in "doujinshi", "mugimugi.org", *rest
      nil

    # https://drawcrowd.com/agussw
    in _, "drawcrowd.com", *rest
      nil

    # http://drawr.net/matsu310
    in _, "drawr.net", *rest
      nil

    # https://www.dropbox.com/sh/gz9okupqycr2vj2/GHt_oHDKsR
    # http://dl.dropbox.com/u/76682289/daitoHP-WP/pict/
    in _, "dropbox.com", *rest
      nil

    # https://www.etsy.com/shop/yeurei
    in _, "etsy.com", *rest
      nil

    # http://www.geocities.jp/nanp002001
    in _, "geocities.jp", *rest
      nil

    # https://plus.google.com/111509637967078773143/posts
    # http://sites.google.com/site/dorumentaiko/
    # https://drive.google.com/drive/folders/1NL1iwZb8o52ieGt-Tkt8AAZu79rqmekj
    # https://drive.google.com/file/d/1LNiTeOS9HFhkElIBGXjVMNdWVW-vkFeZ/view
    in _, "google.com", *rest
      nil

    # https://www.inprnt.com/gallery/zuyuancesartoo/
    in _, "inprnt.com", *rest
      nil

    # http://ecchi.iwara.tv/users/marumega
    in _, "iwara.tv", *rest
      nil

    in _, "kym-cdn.com", *rest
      nil

    in "livedoor", "blogimg.jp", *rest
      nil

    # http://blog.livedoor.jp/ac370ml
    in "blog", "livedoor.jp", *rest
      nil

    # http://www.mangaupdates.com/authors.html?id=15780
    in _, "mangaupdates.com", *rest
      nil

    # http://mblg.tv/ikusanin01/
    in _, "mblg.tv", *rest
      nil

    # https://www.melonbooks.co.jp/circle/index.php?circle_id=15547
    # https://www.melonbooks.co.jp/detail/detail.php?product_id=2391671
    in _, "melonbooks.co.jp", *rest
      nil

    # http://www.melonbooks.com/index.php?main_page=maker_info&makers_id=MK0000016413
    in _, "melonbooks.com", *rest
      nil

    # https://mega.nz/file/9zxwxCDD#TJn7S7sPag30wDVD-kaVhFkeROzz-fE7_ZOb3gIZPTA
    # https://mega.nz/folder/8d4E0LxK#yzYqKHoGFu92RzMNWnoZEw/file/tUgAQZJA
    in _, "mega.nz", *rest
      nil

    # https://www.mihuashi.com/profiles/75614
    # https://www.mihuashi.com/artworks/14704979
    in _, "mihuashi.com", *rest
      nil

    # http://mixi.jp/show_friend.pl?id=310102
    in _, "mixi.jp", *rest
      nil

    # https://monappy.jp/u/abara_bone
    in _, "monappy.jp", *rest
      nil

    # https://mstdn.jp/@oneb
    in _, "mstdn.jp", *rest
      nil

    # http://nanos.jp/riku65/
    in _, "nanos.jp", *rest
      nil

    # https://onlyfans.com/evviart
    in _, "onlyfans.com", *rest
      nil

    # https://peing.net/ja/scape0505kigkig
    in _, "peing.net", *rest
      nil

    # https://picarto.tv/CheckerBoardAZN
    # https://www.picarto.tv/live/channel.php?watch=aaaninja
    in _, "picarto.tv", *rest
      nil

    # http://www.pictaram.com/user/5ish/3048385011/1350040096769940245_3048385011
    in _, "pictaram.com", *rest
      nil

    # http://tegaki.pipa.jp/515745
    # https://tegaki.com/515745/
    in _, ("pipa.jp" | "tegaki.com"), *rest
      nil

    # https://pomf.tv/oozutsucannon
    # https://pomf.tv/stream/Kukseleg
    in _, "pomf.tv", *rest
      nil

    # http://www7.plala.or.jp/reirei
    in _, "plala.or.jp", *rest
      nil

    # https://www.pornhub.com/model/mizzpeachy
    in _, "pornhub.com", *rest
      nil

    # https://www.redbubble.com/people/limb
    in _, "redbubble.com", *rest
      nil

    # https://smutba.se/project/431/
    in _, "smutba.se", *rest
      nil

    # http://society6.com/serafleur/
    in _, "society6.com", *rest
      nil

    # https://soundcloud.com/uwmx4hwforgm
    in _, "soundcloud.com", *rest
      nil

    # https://soundgasm.net/MilkteaMomoko
    in _, "soundgasm.net", *rest
      nil

    # https://steamcommunity.com/id/sobchan
    # https://steamcommunity.com/sharedfiles/filedetails/?id=422092039
    in _, ("steamcommunity.com" | "steamstatic.com"), *rest
      nil

    # https://www.stickam.jp/profile/gyroscope
    in _, "stickam.jp", *rest
      nil

    # https://subscribestar.adult/daivijohn
    # https://subscribestar.adult/posts/1242417
    in _, ("subscribestar.adult" | "subscribestar.com"), *rest
      nil

    # https://superrare.com/mcbess
    in _, "superrare.com", *rest
      nil

    # https://tapas.io/Paroro
    in _, "tapas.io", *rest
      nil

    # https://www.teepublic.com/user/ejsu28
    in _, "teepublic.com", *rest
      nil

    # https://t.me/lystrahut
    in _, "t.me", *rest
      nil

    # http://theinterviews.jp/ruixiang
    in _, "theinterviews.jp", *rest
      nil

    # https://twitcasting.tv/satecoon
    in _, "twitcasting.tv", *rest
      nil

    # https://www.twitch.tv/5ish
    in _, "twitch.tv", *rest
      nil

    # http://www.ustream.tv/channel/633b
    # http://www.ustream.tv/user/kazaputi
    in _, "ustream.tv", *rest
      nil

    # https://vk.com/id425850679
    in _, "vk.com", *rest
      nil

    # http://spibal.webclap.com
    in "spibal", "webclap.com", *rest
      nil

    # https://www.webtoons.com/en/creator/37u4n
    in _, "webtoons.com", *rest
      nil

    # https://en.wikipedia.org/wiki/Hidetaka_Tenjin
    in _, "wikipedia.org", *rest
      nil

    in _, "wp.com", *rest
      nil

    # http://yaplog.jp/niyang53
    in _, "yaplog.jp", *rest
      nil

    else
      @recognized = false

    end
  end

  def recognized?
    @recognized
  end

  # Return `nil` to indicate that we don't know whether it's a bad source or not, since most sites here aren't fully
  # handled. Returning nil means the tag won't be added to or removed from the post.
  def bad_source?
    nil
  end

  def bad_link?
    nil
  end

  def image_sample?
    nil
  end
end
