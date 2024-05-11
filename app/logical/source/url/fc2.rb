# frozen_string_literal: true

class Source::URL::Fc2 < Source::URL
  attr_reader :username, :subsite, :blog_entry, :album_filename, :candidate_full_image_url, :candidate_page_urls

  def self.match?(url)
    url.domain.in?(%w[fc2.com fc2web.com fc2blog.net fc2blog.us])
  end

  def site_name
    "FC2"
  end

  def parse
    case [*host.split("."), *path_segments]

    # http://hosystem.blog36.fc2.com/blog-entry-37.html
    # http://swordsouls.blog131.fc2blog.us/blog-entry-376.html
    # http://swordsouls.blog131.fc2blog.net/blog-entry-376.html
    in username, /^blog\d*$/, ("fc2" | "fc2blog"), _, /^blog-entry-(\d+)\.html$/
      @username = username
      @subsite = "blog"
      @blog_entry = $1

    # http://oekakigakusyuu.blog97.fc2.com/?m&no=320
    # http://abk00.blog71.fc2.com/?no=3052
    in username, /^blog\d*$/, ("fc2" | "fc2blog"), _, *rest if params[:no]&.match?(/^\d+$/)
      @username = username
      @subsite = "blog"
      @blog_entry = params[:no]

    # http://niyamalog.blog.fc2.com/img/20170330Xray6z7P/
    # http://niyamalog.blog.fc2.com/img/bokuomapop.jpg/
    # http://swordsouls.blog131.fc2blog.us/img/20141009132121fb7.jpg/
    in username, /^blog\d*$/, ("fc2" | "fc2blog"), _, "img", file
      @username = username
      @subsite = "blog"
      @album_filename = file

    # http://alternatif.blog26.fc2.com/?mode=image&filename=rakugaki10.jpg
    # http://swordsouls.blog131.fc2blog.us/?mode=image&filename=20141009132121fb7.jpg
    in username, /^blog\d*$/, ("fc2" | "fc2blog"), _, *rest if params[:mode] == "image" && params[:filename].present?
      @username = username
      @subsite = "blog"
      @album_filename = params[:filename]

    # http://silencexs.blog.fc2.com
    # http://silencexs.blog106.fc2.com
    # http://swordsouls.blog131.fc2blog.net
    # http://swordsouls.blog131.fc2blog.us
    # http://niyamalog.blog.fc2.com/imgs/
    # http://orihc.blog13.fc2.com/page-3.html
    # http://onidocoro.blog14.fc2.com/file/20071003061150.png
    # http://mtunk.blog49.fc2.com/blog-date-20101218.html
    # http://mtunk.blog49.fc2.com/?date=20111230
    # http://yoruichi3.blog5.fc2.com/file/neru.jpg
    in username, /^blog\d*$/, ("fc2" | "fc2blog"), _, *rest
      @username = username
      @subsite = "blog"

    # http://794ancientkyoto.web.fc2.com
    # http://yorokobi.x.fc2.com
    # https://lilish28.bbs.fc2.com
    # http://jpmaid.h.fc2.com
    # http://toritokaizoku.web.fc2.com/tori.html (404: http://toritokaizoku.web.fc2.com)
    # http://oriongarlic.web.fc2.com/share/person/4000/O4284.jpg?2047604
    in username, ("bbs" | "web" | "h" | "x") => subsite, "fc2", "com", *rest
      @username = username
      @subsite = subsite

    # http://blog23.fc2.com/m/mosha2/file/uru.jpg
    # http://blog.fc2.com/g/genshi/file/20070612a.jpg
    in /^blog\d*$/, "fc2", "com", /^\w$/, username, "file", _
      @username = username
      @subsite = "blog"

    # http://xkilikox.fc2web.com
    # http://xkilikox.fc2web.com/image/haguruma.html
    # http://xkilikox.fc2web.com/image/haguruma00.jpg
    # http://yappaga.fc2web.com/gallery.html
    in username, "fc2web", "com", *rest
      @username = username

    # https://blog-imgs-119.fc2.com/n/i/y/niyamalog/bokuomapops.jpg (sample)
    # https://blog-imgs-119-origin.fc2.com/n/i/y/niyamalog/bokuomapop.jpg (full)
    # http://blog-imgs-103.fc2.com/k/u/s/kusarenk/kanade_s.jpg (full)
    # http://blog-imgs-99-origin.fc2.com/h/7/2/h723/idkdldss.jpg (full)
    #
    # http://blog-imgs-63-origin.fc2.com/y/u/u/yuukyuukikansya/140817hijiri02.jpg
    # http://blog-imgs-61.fc2.com/o/m/o/omochi6262/20130402080220583.jpg
    # http://blog.fc2.com/g/b/o/gbot/20071023195141.jpg

    # http://blog-imgs-57.fc2blog.us/s/w/o/swordsouls/20141009132121fb7.jpg
    in (/^blog-imgs-\d+(-origin)?$/ | "blog"), ("fc2" | "fc2blog"), _, /^\w$/, /^\w$/, /^\w$/, username, _
      @username = username
      @subsite = "blog"

      if original_url.match?(/s\.jpg$/)
        @candidate_full_image_url = original_url.gsub(/s\.jpg$/, ".jpg")
        @candidate_page_urls = %W[
          http://#{username}.blog.#{domain}/img/#{basename.gsub(/s\.jpg$/, ".jpg")}/
          http://#{username}.blog.#{domain}/img/#{basename}/
        ]
      else
        @candidate_page_urls = ["http://#{username}.blog.#{domain}/img/#{basename}/"]
      end

    # http://diary.fc2.com/user/yuuri/img/2005_12/26.jpg
    # http://diary1.fc2.com/user/kou_48/img/2006_8/14.jpg
    # http://diary.fc2.com/user/kazuharoom/img/2015_5/22.jpg
    in /diary\d*$/, "fc2", "com", "user", username, "img", date, _
      @username = username
      @subsite = "diary"
      @year, @month = date.split("_")
      @day = filename

    # http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom/?Y=2012&M=10&D=22
    in /diary\d*$/, "fc2", "com", "cgi-sys", "ed.cgi", username
      @username = username
      @subsite = "diary"

    # https://clap.fc2.com/uploads/h/o/hoge/hacs.jpg
    else
      nil
    end
  end

  def image_url?
    # http://niyamalog.blog.fc2.com/img/bokuomapop.jpg/ (a page url, not an image url)
    album_filename.present? ? false : super
  end

  def page_url
    # http://hosystem.blog36.fc2.com/blog-entry-37.html
    # http://swordsouls.blog131.fc2blog.us/blog-entry-376.html
    if username.present? && blog_entry.present?
      "http://#{username}.blog.#{domain}/blog-entry-#{blog_entry}.html"

    # http://niyamalog.blog.fc2.com/img/20170330Xray6z7P/
    # http://niyamalog.blog.fc2.com/img/bokuomapop.jpg/
    # http://swordsouls.blog131.fc2blog.us/img/20141009132121fb7.jpg/
    # http://swordsouls.blog131.fc2blog.us/?mode=image&filename=20141009132121fb7.jpg
    elsif username.present? && album_filename.present?
      "http://#{username}.blog.#{domain}/img/#{album_filename}/"

    # http://diary.fc2.com/user/kazuharoom/img/2015_5/22.jpg
    elsif @subsite == "diary" && username.present? && @year.present? && @month.present? && @day.present?
      "http://#{host}/cgi-sys/ed.cgi/#{username}?Y=#{@year}&M=#{@month}&D=#{@day}"
    end
  end

  def profile_url
    # http://hosystem.blog36.fc2.com/blog-entry-37.html
    # http://swordsouls.blog131.fc2blog.us/blog-entry-376.html
    # http://onidocoro.blog14.fc2.com/file/20071003061150.png
    # http://blog.fc2.com/g/genshi/file/20070612a.jpg
    if subsite == "blog" && username.present?
      "http://#{username}.blog.#{domain}"

    # http://diary.fc2.com/user/yuuri/img/2005_12/26.jpg
    # http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom/?Y=2012&M=10&D=22
    elsif subsite == "diary" && username.present?
      "http://diary.fc2.com/cgi-sys/ed.cgi/#{username}"

    # http://794ancientkyoto.web.fc2.com
    # http://yorokobi.x.fc2.com
    # https://lilish28.bbs.fc2.com
    # http://jpmaid.h.fc2.com
    # http://fromh.web.fc2.com/codefromh/top.html
    # http://toritokaizoku.web.fc2.com/tori.html (404: http://toritokaizoku.web.fc2.com)
    # http://tritre.web.fc2.com (404: http://tritre.web.fc2.com/index.html)
    #
    # http://xkilikox.fc2web.com
    # http://yappaga.fc2web.com/gallery.html (404: http://yappaga.fc2web.com)
    # http://naokimk2.fc2web.com/HP2/TOP.html (404: http://naokimk2.fc2web.com)
    #
    # http://xkilikox.fc2web.com/image/haguruma.html (XXX: should be page url, not a profile url)
    elsif (subsite.in?(%w[bbs web h x]) || domain == "fc2web.com") && !image_url?
      URI.join("http://#{host}", path).to_s.chomp("/")

    # http://rxsdm.h.fc2.com/f/061201_2.jpg
    # http://xkilikox.fc2web.com/image/haguruma00.jpg
    elsif image_url? && username.present?
      "http://#{host}"

    end
  end
end
