# frozen_string_literal: true

class Source::URL::Null < Source::URL
  attr_reader :work_id, :page_url, :profile_url

  def self.match?(url)
    true
  end

  def site_name
    case host
    when /ask\.fm\z/i
      "Ask.fm"
    when /bcy\.net\z/i
      "BCY"
    when /carrd\.co\z/i
      "Carrd"
    when /circle\.ms\z/i
      "Circle.ms"
    when /dlsite\.(com|net)\z/i
      "DLSite"
    when /doujinshi\.org\z/i, /doujinshi\.mugimugi\.org\z/i
      "Doujinshi.org"
    when /ko-fi\.com\z/i
      "Ko-fi"
    when /lit\.link\z/i
      "Lit.link"
    when /mixi\.jp\z/i
      "Mixi.jp"
    when /piapro\.jp\z/i
      "Piapro.jp"
    when /sakura\.ne\.jp\z/i
      "Sakura.ne.jp"
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

    # http://com2.doujinantena.com/contents_jpg/cf0224563cf7a75450596308fe651d5f/018.jpg
    # http://sozai.doujinantena.com/contents_jpg/cf0224563cf7a75450596308fe651d5f/009.jpg
    in _, "doujinantena.com", "contents_jpg", /^\h{32}$/ => md5, *rest
      @md5 = md5
      @page_url = "http://doujinantena.com/page.php?id=#{md5}"

    # https://e-shuushuu.net/images/2017-07-19-915628.jpeg
    in _, "e-shuushuu.net", "images", /^\d{4}-\d{2}-\d{2}-(\d+)\.(jpeg|jpg|png|gif)$/i
      @work_id = $1
      @page_url = "https://e-shuushuu.net/image/#{@work_id}"

    # https://scontent.fmnl9-2.fna.fbcdn.net/v/t1.6435-9/196345051_961754654392125_8855002558147907833_n.jpg?_nc_cat=103&ccb=1-5&_nc_sid=0debeb&_nc_ohc=EB1RGiEOtyEAX9XE7aL&_nc_ht=scontent.fmnl9-2.fna&oh=00_AT8NNz_keqQ6VJeC1UVSMULhjaP3iykm-ONSMR7IrtarUQ&oe=6257862E
    # https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/fr/cp0/e15/q65/80900683_480934615898749_6481759463945535488_n.jpg?_nc_cat=107&ccb=1-3&_nc_sid=8024bb&_nc_ohc=cCYFUzyHDmUAX-YHJIw&_nc_ht=scontent.fmnl8-2.fna&oh=e45c3837afcfefb6a4d93adfecef88c1&oe=60F6E392
    # https://scontent.fmnl13-1.fna.fbcdn.net/v/t31.18172-8/22861751_1362164640578443_432921612329393062_o.jpg
    # https://scontent-sin1-1.xx.fbcdn.net/hphotos-xlp1/t31.0-8/s960x960/12971037_586686358150819_495608200196301072_o.jpg
    in _, "fbcdn.net", *subdirs, /^\d+_(\d+)_(?:\d+_){1,3}[no]\.(jpg|png)$/
      @work_id = $1
      @page_url = "https://www.facebook.com/photo?fbid=#{@work_id}"

    # https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xlp1/t31.0-8/s960x960/13173066_623015164516858_1844421675339995359_o.jpg
    # https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/s720x720/12032214_991569624217563_4908408819297057893_n.png?oh=efe6ea26aed89c8a12ddc1832b1f0157&oe=5667D5B1&__gda__=1453845772_c742c726735047f2feb836b845ff296f
    in /fbcdn/, "akamaihd.net", *subdirs, /^\d_(\d+)_(?:\d+_){1,3}[no]\.(jpg|png)$/
      @work_id = $1
      @page_url = "https://www.facebook.com/photo.php?fbid=#{work_id}"

    # https://fori.io/comori22
    in _, "fori.io", username
      @username = username
      @profile_url = "https://www.foriio.com/#{username}"

    # https://www.foriio.com/comori22
    in _, "foriio.com", username
      @username = username
      @profile_url = "https://www.foriio.com/#{username}"

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

    # http://www.karabako.net/images/karabako_43878.jpg
    # http://www.karabako.net/imagesub/karabako_43222_215.jpg
    in _, "karabako.net", ("images" | "imagesub"), /^karabako_(\d+)/
      @work_id = $1
      @page_url = "http://www.karabako.net/post/view/#{work_id}"

    # http://static.minitokyo.net/downloads/31/33/764181.jpg
    in _, "minitokyo.net", "downloads", /^\d{2}$/, /^\d{2}$/, file
      @work_id = filename
      @page_url = "http://gallery.minitokyo.net/view/#{@work_id}"

    # http://i.minus.com/j2LcOC52dGLtB.jpg
    # http://i5.minus.com/ik26grnRJAmYh.jpg
    in _, "minus.com", /^[ij]([a-zA-Z0-9]{12,})\.(jpg|png|gif)$/
      @work_id = $1
      @page_url = "http://minus.com/i/#{@work_id}"

    # http://jpg.nijigen-daiaru.com/7364/013.jpg
    in "jpg", "nijigen-daiaru.com", /^\d+$/ => work_id, file
      @work_id = work_id
      @page_url = "http://nijigen-daiaru.com/book.php?idb=#{@work_id}"

    # http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg
    # http://kura3.photozou.jp/pub/741/2662741/photo/160341863_624.v1353780834.jpg
    in _, "photozou.jp", "pub", /^\d+$/, user_id, "photo", /^(\d+)/ => file
      @user_id = user_id
      @work_id = $1
      @page_url = "https://photozou.jp/photo/show/#{@user_id}/#{@work_id}"

    # https://tulip.paheal.net/_images/4f309b2b680da9c3444ed462bb172214/3910816%20-%20Dark_Magician_Girl%20MINK343%20Yu-Gi-Oh!.jpg
    # http://rule34-data-002.paheal.net/_images/2ab55f9291c8f2c68cdbeac998714028/2401510%20-%20Ash_Ketchum%20Lillie%20Porkyman.jpg
    # http://rule34-images.paheal.net/c4710f05e76bdee22fcd0d62bf1ac840/262685%20-%20mabinogi%20nao.jpg
    in _, "paheal.net", *subdirs, /^\h{32}$/ => md5, /^(\d+)/ => file
      @md5 = md5
      @work_id = $1
      @page_url = "https://rule34.paheal.net/post/view/#{@work_id}"

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

    # http://shimmie.katawa-shoujo.com/image/3657.jpg
    in "shimmie", "katawa-shoujo.com", "image", file
      @work_id = filename
      @page_url = "https://shimmie.katawa-shoujo.com/post/view/#{@work_id}"

    # http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg
    # http://img.toranoana.jp/popup_img18/04/0010/22/87/040010228714-1p.jpg
    # http://img.toranoana.jp/popup_blimg/04/0030/08/30/040030083068-1p.jpg
    # https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg
    in ("img" | "ecdnimg"), "toranoana.jp", *subdirs, /^\d{2}$/, /^\d{4}$/, /^\d{2}$/, /^\d{2}$/, /^(\d{12})-\d+p\.jpg$/ => file
      @work_id = $1
      @page_url = "https://ec.toranoana.jp/tora_r/ec/item/#{@work_id}"

    # http://p.twpl.jp/show/orig/DTaCZ
    # http://p.twpl.jp/show/large/5zack
    # http://p.twipple.jp/show/orig/vXqaU
    in _, ("twpl.jp" | "twipple.jp"), "show", ("large" | "orig"), work_id
      @work_id = work_id
      @page_url = "http://p.twipple.jp/#{work_id}"

    # https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png
    # https://s1.zerochan.net/Cocoa.Cookie.600.2957938.jpg
    # http://static.zerochan.net/full/24/13/90674.jpg
    in _, "zerochan.net", *subdirs, /(\d+)\.(jpg|png|gif)$/
      @work_id = $1
      @page_url = "https://www.zerochan.net/#{@work_id}#full"

    # http://www.zerochan.net/full/1567893
    in _, "zerochan.net", "full", /^\d+$/ => work_id
      @work_id = work_id
      @page_url = "https://www.zerochan.net/#{@work_id}#full"

    else
      @recognized = false

    end
  end

  def recognized?
    @recognized
  end
end
