module ArtistFinder
  module_function

  # Subdomains are automatically included. e.g., "twitter.com" matches "www.twitter.com",
  # "mobile.twitter.com" and any other subdomain of "twitter.com".
  SITE_BLACKLIST = [
    "artstation.com/artist", # http://www.artstation.com/artist/serafleur/
    "www.artstation.com", # http://www.artstation.com/serafleur/
    %r{cdn[ab]?\.artstation\.com/p/assets/images/images}i, # https://cdna.artstation.com/p/assets/images/images/001/658/068/large/yang-waterkuma-b402.jpg?1450269769
    "ask.fm", # http://ask.fm/mikuroko_396
    "bcyimg.com",
    "bcyimg.com/drawer", # https://img9.bcyimg.com/drawer/32360/post/178vu/46229ec06e8111e79558c1b725ebc9e6.jpg
    "bcy.net",
    "bcy.net/illust/detail", # https://bcy.net/illust/detail/32360/1374683
    "bcy.net/u", # http://bcy.net/u/1390261
    "behance.net", # "https://www.behance.net/webang111
    "booru.org",
    "booru.org/drawfriends", # http://img.booru.org/drawfriends//images/36/de65da5f588b76bc1d9de8af976b540e2dff17e2.jpg
    "donmai.us",
    "donmai.us/users", # http://danbooru.donmai.us/users/507162/
    "derpibooru.org",
    "derpibooru.org/tags", # https://derpibooru.org/tags/artist-colon-checkerboardazn
    "deviantart.com",
    "deviantart.net",
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
    "facebook.com", # https://www.facebook.com/LuutenantsLoot
    "fantia.jp", # http://fantia.jp/no100
    "fantia.jp/fanclubs", # https://fantia.jp/fanclubs/1711
    "fav.me", # http://fav.me/d9y1njg
    /blog-imgs-\d+(?:-origin)?\.fc2\.com/i,
    "furaffinity.net",
    "furaffinity.net/user", # http://www.furaffinity.net/user/achthenuts
    "gelbooru.com", # http://gelbooru.com/index.php?page=account&s=profile&uname=junou
    "inkbunny.net", # https://inkbunny.net/achthenuts
    "plus.google.com", # https://plus.google.com/111509637967078773143/posts
    "hentai-foundry.com",
    "hentai-foundry.com/pictures/user", # http://www.hentai-foundry.com/pictures/user/aaaninja/
    "hentai-foundry.com/user", # http://www.hentai-foundry.com/user/aaaninja/profile
    %r{pictures\.hentai-foundry\.com(?:/\w)?}i, # http://pictures.hentai-foundry.com/a/aaaninja/
    "i.imgur.com", # http://i.imgur.com/Ic9q3.jpg
    "instagram.com", # http://www.instagram.com/serafleur.art/
    "iwara.tv",
    "iwara.tv/users", # http://ecchi.iwara.tv/users/marumega
    "kym-cdn.com",
    "livedoor.blogimg.jp",
    "monappy.jp",
    "monappy.jp/u", # https://monappy.jp/u/abara_bone
    "mstdn.jp", # https://mstdn.jp/@oneb
    "www.newgrounds.com", # https://jessxjess.newgrounds.com/
    "newgrounds.com/art/view/", # https://www.newgrounds.com/art/view/jessxjess/avatar-korra
    "nicoseiga.jp",
    "nicoseiga.jp/priv", # http://lohas.nicoseiga.jp/priv/2017365fb6cfbdf47ad26c7b6039feb218c5e2d4/1498430264/6820259
    "nicovideo.jp",
    "nicovideo.jp/user", # http://www.nicovideo.jp/user/317609
    "nicovideo.jp/user/illust", # http://seiga.nicovideo.jp/user/illust/29075429
    "nijie.info", # http://nijie.info/members.php?id=15235
    %r{nijie\.info/nijie_picture}i, # http://pic03.nijie.info/nijie_picture/32243_20150609224803_0.png
    "patreon.com", # http://patreon.com/serafleur
    "pawoo.net", # https://pawoo.net/@148nasuka
    "pawoo.net/web/accounts", # https://pawoo.net/web/accounts/228341
    "picarto.tv", # https://picarto.tv/CheckerBoardAZN
    "picarto.tv/live", # https://www.picarto.tv/live/channel.php?watch=aaaninja
    "pictaram.com", # http://www.pictaram.com/user/5ish/3048385011/1350040096769940245_3048385011
    "pinterest.com", # http://www.pinterest.com/alexandernanitc/
    "pixiv.cc", # http://pixiv.cc/0123456789/
    "pixiv.net", # https://www.pixiv.net/member.php?id=10442390
    "pixiv.net/stacc", # https://www.pixiv.net/stacc/aaaninja2013
    "pixiv.net/fanbox/creator", # https://www.pixiv.net/fanbox/creator/310630
    "pixiv.net/users", # https://www.pixiv.net/users/555603
    "pixiv.net/en/users", # https://www.pixiv.net/en/users/555603
    "i.pximg.net",
    "plurk.com", # http://www.plurk.com/a1amorea1a1
    "privatter.net",
    "privatter.net/u", # http://privatter.net/u/saaaatonaaaa
    "reddit.com/r", # https://www.reddit.com/r/pixiepowderpuff/
    "reddit.com/user", # https://www.reddit.com/user/dishwasher1910
    "rule34.paheal.net",
    "rule34.paheal.net/post/list", # http://rule34.paheal.net/post/list/Reach025/
    "sankakucomplex.com", # https://chan.sankakucomplex.com/?tags=user%3ASubridet
    "society6.com", # http://society6.com/serafleur/
    "tinami.com",
    "tinami.com/creator/profile", # http://www.tinami.com/creator/profile/29024
    "data.tumblr.com",
    /\d+\.media\.tumblr\.com/i,
    "twipple.jp",
    "twipple.jp/user", # http://p.twipple.jp/user/Type10TK
    "twitch.tv", # https://www.twitch.tv/5ish
    "twitpic.com",
    "twitpic.com/photos", # http://twitpic.com/photos/Type10TK
    "twitter.com", # https://twitter.com/akkij0358
    "twitter.com/i/web/status", # https://twitter.com/i/web/status/943446161586733056
    "twimg.com/media", # https://pbs.twimg.com/media/DUUUdD5VMAEuURz.jpg:orig
    "ustream.tv",
    "ustream.tv/channel", # http://www.ustream.tv/channel/633b
    "ustream.tv/user", # http://www.ustream.tv/user/kazaputi
    "vk.com", # https://vk.com/id425850679
    "weibo.com", # http://www.weibo.com/5536681649
    "weibo.com/u",
    "weibo.com/p",
    "wp.com",
    "yande.re",
    "youtube.com",
    "youtube.com/c", # https://www.youtube.com/c/serafleurArt
    "youtube.com/channel", # https://www.youtube.com/channel/UCfrCa2Y6VulwHD3eNd3HBRA
    "youtube.com/user", # https://www.youtube.com/user/148nasuka
    "youtu.be" # http://youtu.be/gibeLKKRT-0
  ]

  SITE_BLACKLIST_REGEXP = Regexp.union(SITE_BLACKLIST.map do |domain|
    domain = Regexp.escape(domain) if domain.is_a?(String)
    %r{\Ahttps?://(?:[a-zA-Z0-9_-]+\.)*#{domain}/\z}i
  end)

  def find_artists(url)
    url = ArtistUrl.normalize(url)
    artists = []

    while artists.empty? && url.size > 10
      u = url.sub(%r{/+$}, "") + "/"
      u = u.to_escaped_for_sql_like.gsub(/\*/, '%') + '%'
      artists += Artist.joins(:urls).where(["artists.is_deleted = FALSE AND artist_urls.normalized_url LIKE ? ESCAPE E'\\\\'", u]).limit(10).order("artists.name").all
      url = File.dirname(url) + "/"

      break if url =~ SITE_BLACKLIST_REGEXP
    end

    Artist.where(id: artists.uniq(&:name).take(20))
  end
end
