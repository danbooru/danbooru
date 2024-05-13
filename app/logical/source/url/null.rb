# frozen_string_literal: true

class Source::URL::Null < Source::URL
  attr_reader :work_id, :page_url, :profile_url

  def self.match?(url)
    true
  end

  def site_name
    case [subdomain, domain]
    in "myship", "7-11.com.tw"
      "7-Eleven MyShip"
    in _, "allmylinks.com"
      "AllMyLinks"
    in _, "animenewsnetwork.com"
      "Anime News Network"
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
    in _, "ask.fm"
      "Ask.fm"
    in _, "gamer.com.tw"
      "Bahamut"
    in _, ("bandcamp.com" | "bcbits.com")
      "Bandcamp"
    in _, "theshop.jp" | "thebase.com"
      "BASE"
    in _, "bigcartel.com"
      "Big Cartel"
    in _, "buymeacoffee.com"
      "Buy Me a Coffee"
    in _, "carrd.co"
      "Carrd"
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
    # XXX curiouscat.qa is possibly a different site
    # https://www.bleepingcomputer.com/news/security/popular-qanda-app-curious-cat-loses-domain-posts-bizarre-tweets/
    in _, ("curiouscat.live" | "curiouscat.me" | "curiouscat.qa")
      "Curious Cat"
    in _, ("dlsite.com" | "dlsite.net" | "dlsite.jp")
      "DLSite"
    in _, "dcinside.com"
      "DC Inside"
    in _, "direct.me"
      "Direct.me"
    in _, "doujinshi.org"
      "Doujinshi.org"
    in "doujinshi", "mugimugi.org"
      "Doujinshi.org"
    in _, "cloudfront.net" if host == "dxthpu4318olx.cloudfront.net"
      "Drawcrowd"
    in _, ("e-hentai.org" | "exhentai.org" | "hath.network")
      "E-Hentai"
    in _, "eth.co"
      "Eth.co"
    in _, "exblog.jp"
      "Excite Blog"
    in _, ("facebook.com" | "fbcdn.net")
      "Facebook"
    in _, ("fandom.com" | "wikia.com")
      "Fandom"
    in _, "fanfiction.net"
      "FanFiction.Net"
    in _, "finalfantasyxiv.com"
      "Final Fantasy XIV"
    in _, ("flickr.com" | "staticflickr.com")
      "Flickr"
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
    in _, "hoyolab.com"
      "HoYoLAB"
    in _, "html.co.jp"
      "html.co.jp"
    in _, "imagecomics.com"
      "Image Comics"
    in _, "instabio.cc" | "linkbio.co"
      "Instabio"
    in _, "itch.io"
      "Itch.io"
    in _, "leagueofcomicgeeks.com"
      "League of Comic Geeks"
    in _, ("line.me" | "line-apps.com")
      "Line"
    in _, ("linkedin.com" | "licdn.com")
      "LinkedIn"
    in _, "linktr.ee"
      "Linktree"
    in _, "livedoor.jp"
      "Livedoor"
    in "livedoor", "blogimg.jp"
      "Livedoor"
    in _, ("2chblog.jp" | "blog.jp" | "bloggeek.jp" | "blogism.jp" | "blogo.jp" | "blogstation.jp" | "blogto.jp" | "cafeblog.jp" | "corpblog.jp" | "diary.to" | "doorblog.jp" | "dreamlog.jp" | "gger.jp" | "golog.jp" | "ldblog.jp" | "liblo.jp" | "livedoor.biz" | "myjournal.jp" | "mynikki.jp" | "officeblog.jp" | "officialblog.jp" | "publog.jp" | "storeblog.jp" | "teamblog.jp" | "techblog.jp" | "weblog.to" | "xxxblog.jp" | "youblog.jp")
      "Livedoor"
    in _, "lit.link"
      "Lit.link"
    in _, ("kirbyscomicart.com"| "kirbyscomicartshop.com")
      "Kirby's Comic Art"
    in _, "kirumade.com"
      "Kiru Made"
    in _, "kemono.party"
      "Kemono Party"
    in _, "ko-fi.com"
      "Ko-fi"
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
    in _, "redgifs.com"
      "RedGIFs"
    in _, "sakura.ne.jp"
      "Sakura.ne.jp"
    in _, "sankakucomplex.com"
      "Sankaku Complex"
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
    in _, ("spotify.com" | "spotifycdn.com")
      "Spotify"
    in _, "square.site" | "squareup.com"
      "Square"
    in _, ("steamstatic.com" | "steamcommunity.com")
      "Steam"
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
    in _, "toyhou.se"
      "Toyhouse"
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
    in _, "wordpress.com"
      "WordPress"
    in _, "youtu.be"
      "Youtube"
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

    # http://about.me/rig22
    in _, "about.me", username
      @username = username
      @profile_url = "https://about.me/#{username}"

    # https://allmylinks.com/hieumayart
    in _, "allmylinks.com", username
      @username = username
      @profile_url = "https://allmylinks.com/#{username}"

    # http://marilyn77.ameblo.jp/
    in username, "ameblo.jp", *rest unless subdomain.in?(["www", "s", nil])
      @username = username
      @profile_url = "https://ameblo.jp/#{username}"

    # https://ameblo.jp/g8set55679
    # http://ameblo.jp/hanauta-os/entry-11860045489.html
    # http://s.ameblo.jp/ma-chi-no/
    in _, "ameblo.jp", username, *rest
      @username = username
      @profile_url = "https://ameblo.jp/#{username}"

    # http://stat.ameba.jp/user_images/20130802/21/moment1849/38/bd/p
    # http://stat001.ameba.jp/user_images/20100212/15/weekend00/74/31/j/
    in /^stat\d*$/, "ameba.jp", "user_images", _, _, username, *rest
      @username = username
      @profile_url = "https://ameblo.jp/#{username}"

    # https://profile.ameba.jp/ameba/kbnr32rbfs
    in "profile", "ameba.jp", "ameba", username
      @username = username
      @profile_url = "https://ameblo.jp/#{username}"

    # https://anidb.net/creator/65313
    in _, "anidb.net", "creator", user_id
      @user_id = user_id
      @profile_url = "https://anidb.net/creator/#{user_id}"

    # https://anidb.net/perl-bin/animedb.pl?show=creator&creatorid=3903
    in _, "anidb.net", "perl-bin", "animedb.pl" if params[:show] == "creator" and params[:creatorid].present?
      @user_id = params[:creatorid]
      @profile_url = "https://anidb.net/creator/#{user_id}"

    # https://www.animenewsnetwork.com/encyclopedia/people.php?id=17056
    in _, ("animenewsnetwork.com" | "animenewsnetwork.cc"), "encyclopedia", "people.php" if params[:id].present?
      @user_id = params[:id]
      @profile_url = "https://www.animenewsnetwork.com/encyclopedia/people.php?id=#{params[:id]}"

    # https://ask.fm/kiminaho
    # https://m.ask.fm/kiminaho
    # http://ask.fm/cyoooooon/best
    in _, "ask.fm", username, *rest
      @username = username
      @profile_url = "https://ask.fm/#{username}"

    # http://hi.baidu.com/lizzydom
    # http://hi.baidu.com/longbb1127/home
    # http://hi.baidu.com/new/mocaorz
    in _, "baidu.com", *rest
      nil

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

    # http://nekomataya.net/diarypro/data/upfile/66-1.jpg
    # http://www117.sakura.ne.jp/~cat_rice/diarypro/data/upfile/31-1.jpg
    # http://webknight0.sakura.ne.jp/cgi-bin/diarypro/data/upfile/9-1.jpg
    in _, _, *subdirs, "diarypro", "data", "upfile", /^(\d+)-\d+\.(jpg|png|gif)$/ => file
      @work_id = $1
      @page_url = [site, *subdirs, "diarypro/diary.cgi?no=#{@work_id}"].join("/")

    # http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=723-4.jpg
    # http://www.danshaku.sakura.ne.jp/cgi-bin/diarypro/diary.cgi?mode=image&upfile=56-1.jpg
    # http://www.yanbow.com/~myanie/diarypro/diary.cgi?mode=image&upfile=279-1.jpg
    in _, _, *subdirs, "diarypro", "diary.cgi" if params[:mode] == "image" && params[:upfile].present?
      @work_id = params[:upfile][/^\d+/]
      @page_url = [site, *subdirs, "diarypro/diary.cgi?no=#{@work_id}"].join("/")

    in _, "dlsite.com", *rest
      nil

    # http://com2.doujinantena.com/contents_jpg/cf0224563cf7a75450596308fe651d5f/018.jpg
    # http://sozai.doujinantena.com/contents_jpg/cf0224563cf7a75450596308fe651d5f/009.jpg
    in _, "doujinantena.com", "contents_jpg", /^\h{32}$/ => md5, *rest
      @md5 = md5
      @page_url = "http://doujinantena.com/page.php?id=#{md5}"

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

    # https://e-hentai.org/tag/artist:spirale
    # https://e-hentai.org/uploader/Spirale
    in _, "e-hentai.org", *rest
      nil

    # https://e-shuushuu.net/images/2017-07-19-915628.jpeg
    in _, "e-shuushuu.net", "images", /^\d{4}-\d{2}-\d{2}-(\d+)\.(jpeg|jpg|png|gif)$/i
      @work_id = $1
      @page_url = "https://e-shuushuu.net/image/#{@work_id}"

    # https://www.etsy.com/shop/yeurei
    in _, "etsy.com", *rest
      nil

    # https://scontent.fmnl9-2.fna.fbcdn.net/v/t1.6435-9/196345051_961754654392125_8855002558147907833_n.jpg?_nc_cat=103&ccb=1-5&_nc_sid=0debeb&_nc_ohc=EB1RGiEOtyEAX9XE7aL&_nc_ht=scontent.fmnl9-2.fna&oh=00_AT8NNz_keqQ6VJeC1UVSMULhjaP3iykm-ONSMR7IrtarUQ&oe=6257862E
    # https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/fr/cp0/e15/q65/80900683_480934615898749_6481759463945535488_n.jpg?_nc_cat=107&ccb=1-3&_nc_sid=8024bb&_nc_ohc=cCYFUzyHDmUAX-YHJIw&_nc_ht=scontent.fmnl8-2.fna&oh=e45c3837afcfefb6a4d93adfecef88c1&oe=60F6E392
    # https://scontent.fmnl13-1.fna.fbcdn.net/v/t31.18172-8/22861751_1362164640578443_432921612329393062_o.jpg
    # https://scontent-sin1-1.xx.fbcdn.net/hphotos-xlp1/t31.0-8/s960x960/12971037_586686358150819_495608200196301072_o.jpg
    in _, "fbcdn.net", *subdirs, /^\d+_(\d+)_(?:\d+_){1,3}[no]\.(jpg|png)$/
      @work_id = $1
      @page_url = "https://www.facebook.com/photo?fbid=#{@work_id}"

    # https://www.facebook.com/LuutenantsLoot
    in _, ("facebook.com" | "fbcdn.net"), *rest
      nil

    # https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xlp1/t31.0-8/s960x960/13173066_623015164516858_1844421675339995359_o.jpg
    # https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/s720x720/12032214_991569624217563_4908408819297057893_n.png?oh=efe6ea26aed89c8a12ddc1832b1f0157&oe=5667D5B1&__gda__=1453845772_c742c726735047f2feb836b845ff296f
    in /fbcdn/, "akamaihd.net", *subdirs, /^\d_(\d+)_(?:\d+_){1,3}[no]\.(jpg|png)$/
      @work_id = $1
      @page_url = "https://www.facebook.com/photo.php?fbid=#{work_id}"

    # https://www.flickr.com/people/shirasaki408/
    # https://www.flickr.com/photos/shirasaki408/
    # https://www.flickr.com/photos/shirasaki408/albums
    # https://www.flickr.com/photos/hizna/sets/72157629448846789/
    # https://www.flickr.com/photos/shirasaki408/49398982266/
    in _, "flickr.com", ("people" | "photos"), username, *rest
      @profile_url = "https://www.flickr.com/people/#{username}"

    # http://www.geocities.jp/nanp002001
    in _, "geocities.jp", *rest
      nil

    # https://plus.google.com/111509637967078773143/posts
    # http://sites.google.com/site/dorumentaiko/
    in _, "google.com", *rest
      nil

    # https://a.hitomi.la/galleries/907838/1.png
    # https://0a.hitomi.la/galleries/1169701/23.png
    # https://aa.hitomi.la/galleries/990722/003_01_002.jpg
    # https://la.hitomi.la/galleries/1054851/001_main_image.jpg
    in _, "hitomi.la", "galleries", gallery_id, /^(\d+)\w*\.(jpg|png|gif)$/ => image_id
      @gallery_id = gallery_id
      @image_id = $1.to_i
      @page_url = "https://hitomi.la/reader/#{gallery_id}.html##{@image_id}"

    # https://aa.hitomi.la/galleries/883451/t_rena1g.png
    in _, "hitomi.la", "galleries", gallery_id, file
      @gallery_id = gallery_id
      @page_url = "https://hitomi.la/galleries/#{gallery_id}.html"

    # https://www.inprnt.com/gallery/zuyuancesartoo/
    in _, "inprnt.com", *rest
      nil

    # http://ecchi.iwara.tv/users/marumega
    in _, "iwara.tv", *rest
      nil

    # http://www.karabako.net/images/karabako_43878.jpg
    # http://www.karabako.net/imagesub/karabako_43222_215.jpg
    in _, "karabako.net", ("images" | "imagesub"), /^karabako_(\d+)/
      @work_id = $1
      @page_url = "http://www.karabako.net/post/view/#{work_id}"

    # https://ko-fi.com/johndaivid
    in _, "ko-fi.com", *rest
      nil

    in _, "kym-cdn.com", *rest
      nil

    # https://linktr.ee/cxlinray
    # https://linktr.ee/seamonkey_op?utm_source=linktree_admin_share
    in _, "linktr.ee", username
      @profile_url = "https://linktr.ee/#{username}"

    in "livedoor", "blogimg.jp", *rest
      nil

    # http://blog.livedoor.jp/ac370ml
    in "blog", "livedoor.jp", *rest
      nil

    # http://www.mangaupdates.com/authors.html?id=15780
    in _, "mangaupdates.com", *rest
      nil

    # https://marshmallow-qa.com/nlo74593630
    in _, "marshmallow-qa.com", *rest
      nil

    # http://mblg.tv/ikusanin01/
    in _, "mblg.tv", *rest
      nil

    # https://www.melonbooks.co.jp/circle/index.php?circle_id=15547
    in _, "melonbooks.co.jp", *rest
      nil

    # http://www.melonbooks.com/index.php?main_page=maker_info&makers_id=MK0000016413
    in _, "melonbooks.com", *rest
      nil

    # https://mega.nz/file/9zxwxCDD#TJn7S7sPag30wDVD-kaVhFkeROzz-fE7_ZOb3gIZPTA
    # https://mega.nz/file/9zxwxCDD#TJn7S7sPag30wDVD-kaVhFkeROzz-fE7_ZOb3gIZPTA
    # https://mega.nz/folder/8d4E0LxK#yzYqKHoGFu92RzMNWnoZEw/file/tUgAQZJA
    in _, "mega.nz", *rest
      nil

    # https://www.mihuashi.com/profiles/75614
    in _, "mihuashi.com", *rest
      nil

    # http://static.minitokyo.net/downloads/31/33/764181.jpg
    in _, "minitokyo.net", "downloads", /^\d{2}$/, /^\d{2}$/, file
      @work_id = filename
      @page_url = "http://gallery.minitokyo.net/view/#{@work_id}"

    # http://i.minus.com/j2LcOC52dGLtB.jpg
    # http://i5.minus.com/ik26grnRJAmYh.jpg
    in _, "minus.com", /^[ij]([a-zA-Z0-9]{12,})\.(jpg|png|gif)$/
      @work_id = $1
      @page_url = "http://minus.com/i/#{@work_id}"

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

    # http://jpg.nijigen-daiaru.com/7364/013.jpg
    in "jpg", "nijigen-daiaru.com", /^\d+$/ => work_id, file
      @work_id = work_id
      @page_url = "http://nijigen-daiaru.com/book.php?idb=#{@work_id}"

    # https://odaibako.net/u/NLO74593630
    in _, "odaibako.net", *rest
      nil

    # https://onlyfans.com/evviart
    in _, "onlyfans.com", *rest
      nil

    # https://peing.net/ja/scape0505kigkig
    in _, "peing.net", *rest
      nil

    # http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg
    # http://kura3.photozou.jp/pub/741/2662741/photo/160341863_624.v1353780834.jpg
    in _, "photozou.jp", "pub", /^\d+$/, user_id, "photo", /^(\d+)/ => file
      @user_id = user_id
      @work_id = $1
      @page_url = "https://photozou.jp/photo/show/#{@user_id}/#{@work_id}"

    # http://photozou.jp/photo/top/941038
    in _, "photozou.jp", *rest
      nil

    # https://picarto.tv/CheckerBoardAZN
    # https://www.picarto.tv/live/channel.php?watch=aaaninja
    in _, "picarto.tv", *rest
      nil

    # http://www.pictaram.com/user/5ish/3048385011/1350040096769940245_3048385011
    in _, "pictaram.com", *rest
      nil

    # http://tegaki.pipa.jp/515745
    in _, "pipa.jp", *rest
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

    # https://privatter.net/u/minami_152133
    # https://privatter.net/m/minami_152133
    in _, "privatter.net", ("u" | "m"), username
      @profile_url = "https://privatter.net/u/#{username}"

    # https://www.redbubble.com/people/limb
    in _, "redbubble.com", *rest
      nil

    # https://tulip.paheal.net/_images/4f309b2b680da9c3444ed462bb172214/3910816%20-%20Dark_Magician_Girl%20MINK343%20Yu-Gi-Oh!.jpg
    # http://rule34-data-002.paheal.net/_images/2ab55f9291c8f2c68cdbeac998714028/2401510%20-%20Ash_Ketchum%20Lillie%20Porkyman.jpg
    # http://rule34-images.paheal.net/c4710f05e76bdee22fcd0d62bf1ac840/262685%20-%20mabinogi%20nao.jpg
    in _, "paheal.net", *subdirs, /^\h{32}$/ => md5, /^(\d+)/ => file
      @md5 = md5
      @work_id = $1
      @page_url = "https://rule34.paheal.net/post/view/#{@work_id}"

    # http://rule34.paheal.net/post/list/Reach025/
    in _, "paheal.net", *rest
      nil

    # https://api-cdn-mp4.rule34.xxx/images/4330/2f85040320f64c0e42128a8b8f6071ce.mp4
    # https://ny5webm.rule34.xxx//images/4653/3c63956b940d0ff565faa8c7555b4686.mp4?5303486
    # https://img.rule34.xxx//images/4977/7d76919c2f713c580f69fe129d2d1a44.jpeg?5668795
    # http://rule34.xxx//images/993/5625625970c9ce8c5121fde518c2c4840801cd29.jpg?992983
    # http://img3.rule34.xxx/img/rule34//images/1180/76c6497b5138c4122710c2d05458e729a8d34f7b.png?1190815
    # http://aimg.rule34.xxx//samples/1267/sample_d628f215f27815dc9c1d365a199ee68e807efac1.jpg?1309664
    in _, "rule34.xxx", ("images" | "samples"), *subdirs, /^(?:sample_)?(\h{32})\.(jpg|jpeg|png|gif|webm|mp4)$/
      @md5 = $1
      @page_url = "https://rule34.xxx/index.php?page=post&s=list&md5=#{$1}"

    # https://cs.sankakucomplex.com/data/68/6c/686ceee03af38fe4ceb45bf1c50947e0.jpg?e=1591893718&m=fLlJfTrK_j2Rnc0uIHNC3w
    # https://v.sankakucomplex.com/data/24/ff/24ff5da1fd7ed051b083b36e4e51de8e.mp4?e=1644999580&m=-OtZg2QdtKbibMte8vlsdw&expires=1644999580&token=0YUdUKKwTmvpozhG1WW_nRvSUQw3WJd574andQv-KYY
    # https://cs.sankakucomplex.com/data/sample/2a/45/sample-2a45c67281b0fcfd26208063f81a3114.jpg?e=1590609355&m=cexHhVyJguoZqPB3z3N7aA
    # http://c3.sankakucomplex.com/data/sample/8a/44/preview8a44211650e818ef07e5d00284c20a14.jpg
    in _, "sankakucomplex.com", "data", *subdirs, /^(?:preview|sample-)?(\h{32})\.(jpg|jpeg|gif|png|webm|mp4)$/
      @md5 = $1
      @page_url = "https://chan.sankakucomplex.com/post/show?md5=#{@md5}"

    # https://chan.sankakucomplex.com/?tags=user%3ASubridet
    in _, "sankakucomplex.com", *rest
      nil

    # http://shimmie.katawa-shoujo.com/image/3657.jpg
    in "shimmie", "katawa-shoujo.com", "image", file
      @work_id = filename
      @page_url = "https://shimmie.katawa-shoujo.com/post/view/#{@work_id}"

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
    in _, ("steamcommunity.com" | "steamstatic.com"), *rest
      nil

    # https://www.stickam.jp/profile/gyroscope
    in _, "stickam.jp", *rest
      nil

    # https://subscribestar.adult/daivijohn
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

    # http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg
    # http://img.toranoana.jp/popup_img18/04/0010/22/87/040010228714-1p.jpg
    # http://img.toranoana.jp/popup_blimg/04/0030/08/30/040030083068-1p.jpg
    # https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg
    in ("img" | "ecdnimg"), "toranoana.jp", *subdirs, /^\d{2}$/, /^\d{4}$/, /^\d{2}$/, /^\d{2}$/, /^(\d{12})-\d+p\.jpg$/ => file
      @work_id = $1
      @page_url = "https://ec.toranoana.jp/tora_r/ec/item/#{@work_id}"

    # https://toyhou.se/Dreaming-Witch
    in _, "toyhou.se", *rest
      nil

    # https://twitcasting.tv/satecoon
    in _, "twitcasting.tv", *rest
      nil

    # https://www.twitch.tv/5ish
    in _, "twitch.tv", *rest
      nil

    # http://p.twpl.jp/show/orig/DTaCZ
    # http://p.twpl.jp/show/large/5zack
    # http://p.twipple.jp/show/orig/vXqaU
    in _, ("twpl.jp" | "twipple.jp"), "show", ("large" | "orig"), work_id
      @work_id = work_id
      @page_url = "http://p.twipple.jp/#{work_id}"

    # https://twpf.jp/swacoro
    in _, "twpl.jp", username
      @profile_url = "https://twpf.jp/#{username}"

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

    # http://yfrog.com/user/0128sinonome/photos
    in _, "yfrog.com", *rest
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
end
