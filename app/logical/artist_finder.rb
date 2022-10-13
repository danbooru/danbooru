# frozen_string_literal: true

# Find the artist entry for a given artist profile URL.
module ArtistFinder
  module_function

  # Subdomains are automatically included. e.g., "twitter.com" matches "www.twitter.com",
  # "mobile.twitter.com" and any other subdomain of "twitter.com".
  SITE_BLACKLIST = [
    "about.me", # http://about.me/rig22
    "allmylinks.com", # https://allmylinks.com/hieumayart
    "ameblo.jp", # https://ameblo.jp/g8set55679
    "ameba.jp", # https://profile.ameba.jp/ameba/kbnr32rbfs
    "anidb.net", # https://anidb.net/creator/65313
    "anifty.jp", # https://anifty.jp/@unagi189
    %r{anifty.jp/(?:ja|zh|en)}, # https://anifty.jp/ja/@unagi189
    "animenewsnetwork.com", # http://www.animenewsnetwork.com/encyclopedia/people.php?id=46869
    "artstation.com/artist", # http://www.artstation.com/artist/serafleur/
    "www.artstation.com", # http://www.artstation.com/serafleur/
    %r{cdn[ab]?\.artstation\.com/p/assets/images/images}i, # https://cdna.artstation.com/p/assets/images/images/001/658/068/large/yang-waterkuma-b402.jpg?1450269769
    "ask.fm", # http://ask.fm/mikuroko_396
    "baidu.com", # http://hi.baidu.com/batscave
    "baraag.net",
    "bcyimg.com",
    "bcyimg.com/drawer", # https://img9.bcyimg.com/drawer/32360/post/178vu/46229ec06e8111e79558c1b725ebc9e6.jpg
    "bcy.net",
    "bcy.net/illust/detail", # https://bcy.net/illust/detail/32360/1374683
    "bcy.net/u", # http://bcy.net/u/1390261
    "behance.net", # "https://www.behance.net/webang111
    "bilibili.com", # https://space.bilibili.com/1500665980
    "booru.org",
    "booru.org/drawfriends", # http://img.booru.org/drawfriends//images/36/de65da5f588b76bc1d9de8af976b540e2dff17e2.jpg
    "comiczin.jp", # https://shop.comiczin.jp/products/list.php?category_id=3394
    "curiouscat.me", # https://curiouscat.me/azurane
    "crepu.net", # https://crepu.net/user/Mizunouchilucia
    "donmai.us",
    "donmai.us/users", # http://danbooru.donmai.us/users/507162/
    "derpibooru.org",
    "derpibooru.org/tags", # https://derpibooru.org/tags/artist-colon-checkerboardazn
    "deviantart.com",
    "deviantart.net",
    "discord.gg", # https://discord.gg/fM8rJZ7SRM
    "dlsite.com",
    "doujinshi.org",
    "doujinshi.org/browse/circle", # http://www.doujinshi.org/browse/circle/65368/
    "doujinshi.org/browse/author", # http://www.doujinshi.org/browse/author/979/23/
    "doujinshi.mugimugi.org",
    "doujinshi.mugimugi.org/browse/author", # http://doujinshi.mugimugi.org/browse/author/3029/
    "doujinshi.mugimugi.org/browse/circle", # http://doujinshi.mugimugi.org/browse/circle/7210/
    "drawcrowd.net", # https://drawcrowd.com/agussw
    "drawr.net", # http://drawr.net/matsu310
    "dropbox.com",
    "dropbox.com/sh", # https://www.dropbox.com/sh/gz9okupqycr2vj2/GHt_oHDKsR
    "dropbox.com/u", # http://dl.dropbox.com/u/76682289/daitoHP-WP/pict/
    "e-hentai.org", # https://e-hentai.org/tag/artist:spirale
    "e621.net",
    "e621.net/post/index/1", # https://e621.net/post/index/1/spirale
    "enty.jp", # https://enty.jp/aizawachihiro888
    "enty.jp/users", # https://enty.jp/users/3766
    "etsy.com", # https://www.etsy.com/shop/yeurei
    "facebook.com", # https://www.facebook.com/LuutenantsLoot
    "fantia.jp", # http://fantia.jp/no100
    "fantia.jp/fanclubs", # https://fantia.jp/fanclubs/1711
    "fantia.jp/posts", # https://fantia.jp/posts/20000
    "fantia.jp/products", # https://fantia.jp/products/10000
    "fav.me", # http://fav.me/d9y1njg
    /blog-imgs-\d+(?:-origin)?\.fc2\.com/i,
    %r{blog\.fc2\.com(/\w)+/?}i, # http://blog71.fc2.com/a/abk00/file/20080220194219.jpg
    "foundation.app",
    "foriio.com", # https://www.foriio.com/comori22
    "flickr.com", # https://www.flickr.com/photos/52tracy
    "furaffinity.net",
    "furaffinity.net/user", # http://www.furaffinity.net/user/achthenuts
    "gelbooru.com", # http://gelbooru.com/index.php?page=account&s=profile&uname=junou
    "geocities.jp", # http://www.geocities.jp/nanp002001
    "inprnt.com", # https://www.inprnt.com/gallery/zuyuancesartoo/
    "inkbunny.net", # https://inkbunny.net/achthenuts
    "itaku.ee", # https://itaku.ee/profile/lewdcactus64
    "google.com", # https://plus.google.com/111509637967078773143/posts
    "hentai-foundry.com",
    "hentai-foundry.com/pictures/user", # http://www.hentai-foundry.com/pictures/user/aaaninja/
    "hentai-foundry.com/user", # http://www.hentai-foundry.com/user/aaaninja/profile
    %r{pictures\.hentai-foundry\.com(?:/\w)?}i, # http://pictures.hentai-foundry.com/a/aaaninja/
    "i.imgur.com", # http://i.imgur.com/Ic9q3.jpg
    "instagram.com", # http://www.instagram.com/serafleur.art/
    "instagram.com/p", # https://www.instagram.com/p/CT79fEjhDwo/
    "iwara.tv",
    "iwara.tv/users", # http://ecchi.iwara.tv/users/marumega
    "ko-fi.com", # https://ko-fi.com/johndaivid
    "kym-cdn.com",
    "linktr.ee", # https://linktr.ee/cxlinray
    "livedoor.blogimg.jp",
    "blog.livedoor.jp", # http://blog.livedoor.jp/ac370ml
    "mangaupdates.com", # http://www.mangaupdates.com/authors.html?id=15780
    "marshmallow-qa.com", # https://marshmallow-qa.com/nlo74593630
    "medibang.com", # https://medibang.com/u/reionemorelight/
    "melonbooks.co.jp", # https://www.melonbooks.co.jp/circle/index.php?circle_id=15547
    "melonbooks.com", # http://www.melonbooks.com/index.php?main_page=maker_info&makers_id=MK0000016413
    "mega.nz", # https://mega.nz/file/9zxwxCDD#TJn7S7sPag30wDVD-kaVhFkeROzz-fE7_ZOb3gIZPTA
    "mega.nz/file", # https://mega.nz/file/9zxwxCDD#TJn7S7sPag30wDVD-kaVhFkeROzz-fE7_ZOb3gIZPTA
    "mega.nz/folder", # https://mega.nz/folder/8d4E0LxK#yzYqKHoGFu92RzMNWnoZEw/file/tUgAQZJA
    "mihuashi.com", # https://www.mihuashi.com/profiles/75614
    "mixi.jp", #http://mixi.jp/show_friend.pl?id=310102
    "mlbg.tv", # http://mblg.tv/ikusanin01/
    "monappy.jp",
    "monappy.jp/u", # https://monappy.jp/u/abara_bone
    "mstdn.jp", # https://mstdn.jp/@oneb
    "nanos.jp", # http://nanos.jp/riku65/
    "naver.com", # https://blog.naver.com/yanusunya
    "www.newgrounds.com", # https://jessxjess.newgrounds.com/
    "newgrounds.com/art/view/", # https://www.newgrounds.com/art/view/jessxjess/avatar-korra
    "nicoseiga.jp",
    "nicoseiga.jp/priv", # http://lohas.nicoseiga.jp/priv/2017365fb6cfbdf47ad26c7b6039feb218c5e2d4/1498430264/6820259
    "nicovideo.jp",
    "nicovideo.jp/user", # http://www.nicovideo.jp/user/317609
    "nicovideo.jp/user/illust", # http://seiga.nicovideo.jp/user/illust/29075429
    "nijie.info", # http://nijie.info/members.php?id=15235
    %r{nijie\.info/nijie_picture}i, # http://pic03.nijie.info/nijie_picture/32243_20150609224803_0.png
    "odaibako.net", # https://odaibako.net/u/NLO74593630
    "onlyfans.com", # https://onlyfans.com/evviart
    "opensea.io", # https://opensea.io/hebitsukai
    "patreon.com", # http://patreon.com/serafleur
    "pawoo.net", # https://pawoo.net/@148nasuka
    "pawoo.net/web/accounts", # https://pawoo.net/web/accounts/228341
    "peing.net", # https://peing.net/ja/scape0505kigkig
    "photozou.jp", # http://photozou.jp/photo/top/941038
    "piapro.jp", # https://piapro.jp/mmm0
    "picarto.tv", # https://picarto.tv/CheckerBoardAZN
    "picarto.tv/live", # https://www.picarto.tv/live/channel.php?watch=aaaninja
    "pictaram.com", # http://www.pictaram.com/user/5ish/3048385011/1350040096769940245_3048385011
    "pinterest.com", # http://www.pinterest.com/alexandernanitc/
    "pipa.jp", # http://tegaki.pipa.jp/515745
    "pixiv.cc", # http://pixiv.cc/0123456789/
    "pixiv.me", # https://pixiv.me/gmgm0327
    "pixiv.net", # https://www.pixiv.net/member.php?id=10442390
    "pixiv.net/stacc", # https://www.pixiv.net/stacc/aaaninja2013
    "pixiv.net/fanbox/creator", # https://www.pixiv.net/fanbox/creator/310630
    %r{pixiv.net/(?:en/)?users}i, # https://www.pixiv.net/users/555603
    %r{pixiv.net/(?:en/)?artworks}i, # https://www.pixiv.net/en/artworks/85241178
    "i.pximg.net",
    "poipiku.com", # https://poipiku.com/1776623/
    "pomf.tv", # https://pomf.tv/oozutsucannon
    "pomf.tv/stream", # https://pomf.tv/stream/Kukseleg
    "plala.or.jp", # http://www7.plala.or.jp/reirei
    "plurk.com", # http://www.plurk.com/a1amorea1a1
    "pornhub.com", # https://www.pornhub.com/model/mizzpeachy
    "privatter.net",
    "privatter.net/u", # http://privatter.net/u/saaaatonaaaa
    "redbubble.com", # https://www.redbubble.com/people/limb
    "reddit.com/r", # https://www.reddit.com/r/pixiepowderpuff/
    "reddit.com/user", # https://www.reddit.com/user/dishwasher1910
    "rule34.paheal.net",
    "rule34.paheal.net/post/list", # http://rule34.paheal.net/post/list/Reach025/
    "sankakucomplex.com", # https://chan.sankakucomplex.com/?tags=user%3ASubridet
    "smutba.se", # https://smutba.se/project/431/
    "society6.com", # http://society6.com/serafleur/
    "soundcloud.com", # https://soundcloud.com/uwmx4hwforgm
    "soundgasm.net", # https://soundgasm.net/MilkteaMomoko
    "skeb.jp", # https://skeb.jp/@212kisaragi
    "steamcommunity.com", # https://steamcommunity.com/id/sobchan
    "stickam.jp", # https://www.stickam.jp/profile/gyroscope
    "subscribestar.adult", # https://subscribestar.adult/daivijohn
    "superrare.com", # https://superrare.com/mcbess
    "t.me", # https://t.me/lystrahut
    "tapas.io", # https://tapas.io/Paroro
    "teepublic.com", # https://www.teepublic.com/user/ejsu28
    "theinterviews.jp", # http://theinterviews.jp/ruixiang
    "tinami.com",
    "tinami.com/creator/profile", # http://www.tinami.com/creator/profile/29024
    "toranoana.jp", # https://ec.toranoana.jp/tora_r/ec/cot/circle/2UPAD06P8V73dC69d687/all/
    "toyhou.se", # https://toyhou.se/Dreaming-Witch
    "data.tumblr.com",
    /\d+\.media\.tumblr\.com/i,
    "twipple.jp",
    "twipple.jp/user", # http://p.twipple.jp/user/Type10TK
    "twitcasting.tv", # https://twitcasting.tv/satecoon
    "twitch.tv", # https://www.twitch.tv/5ish
    "twitpic.com",
    "twitpic.com/photos", # http://twitpic.com/photos/Type10TK
    "twitter.com", # https://twitter.com/akkij0358
    "twitter.com/i/web/status", # https://twitter.com/i/web/status/943446161586733056
    "twitter.com/i/user", # https://twitter.com/i/user/1099260120263880705
    "twitter.com/intent/user", # https://twitter.com/intent/user?user_id=1099260120263880705
    "twimg.com/media", # https://pbs.twimg.com/media/DUUUdD5VMAEuURz.jpg:orig
    "twpf.jp", # https://twpf.jp/swacoro
    "ustream.tv",
    "ustream.tv/channel", # http://www.ustream.tv/channel/633b
    "ustream.tv/user", # http://www.ustream.tv/user/kazaputi
    "vk.com", # https://vk.com/id425850679
    "webclap.com", # http://spibal.webclap.com
    "webtoons.com", # https://www.webtoons.com/en/creator/37u4n
    "weibo.com", # https://weibo.com/kisinSheya
    "weibo.com/u", # https://weibo.com/u/2904950533
    "weibo.com/p", # https://weibo.com/p/1005057075896216
    "weibo.cn", # https://weibo.cn/kisinSheya
    "weibo.cn/u", # https://m.weibo.cn/u/6531786273
    "weibo.cn/p", # https://m.weibo.cn/p/1005055921792975
    "wikipedia.org", # https://en.wikipedia.org/wiki/Hidetaka_Tenjin
    "wp.com",
    "yande.re",
    "yaplog.jp", # http://yaplog.jp/niyang53
    "yfrog.com", # http://yfrog.com/user/0128sinonome/photos
    "youtube.com",
    "youtube.com/c", # https://www.youtube.com/c/serafleurArt
    "youtube.com/channel", # https://www.youtube.com/channel/UCfrCa2Y6VulwHD3eNd3HBRA
    "youtube.com/user", # https://www.youtube.com/user/148nasuka
    "youtu.be" # http://youtu.be/gibeLKKRT-0
  ]

  SITE_BLACKLIST_REGEXP = Regexp.union(SITE_BLACKLIST.map do |domain|
    domain = Regexp.escape(domain) if domain.is_a?(String)
    %r{\A(?:[a-zA-Z0-9_-]+\.)*#{domain}}i
  end)

  # Find the artist for a given artist profile URL. May return multiple Artists
  # in the event of duplicate artist entries.
  #
  # Uses a path-stripping algorithm to find any artist URL that is a prefix
  # of the given URL. A site blacklist is used to prevent false positives.
  #
  # @param url [String] the artist profile URL
  # @return [Array<Artist>] the list of matching artists
  def find_artists(url)
    return Artist.none if url.blank?

    url = ArtistURL.normalize_url(url)

    # First try an exact match
    artists = Artist.active.joins(:urls).where(urls: { url: url })

    # If that fails, try removing the rightmost path component until we find an artist URL that matches the current URL.
    url = url.downcase.gsub(%r{\Ahttps?://|/\z}, "") # "https://example.com/A/B/C/" => "example.com/a/b/c"
    while artists.empty? && url != "."
      u = url.gsub("*", '\*') + "/*"
      artists += Artist.active.joins(:urls).where_like("regexp_replace(lower(artist_urls.url), '^https?://|/$', '', 'g') || '/'", u).limit(10)

      # File.dirname("example.com/a/b/c") => "example.com/a/b"; File.dirname("example.com") => "."
      url = File.dirname(url)

      break if url =~ SITE_BLACKLIST_REGEXP
    end

    # Assume no matches if we found too may duplicates.
    return Artist.none if artists.size >= 4

    Artist.where(id: artists.uniq.take(20))
  end
end
