# frozen_string_literal: true

class Source::URL::Moebooru < Source::URL
  attr_reader :work_id, :md5, :original_file_ext

  def self.match?(url)
    url.domain.in?(%w[yande.re konachan.com])
  end

  def parse
    case [domain, *path_segments]

    # https://yande.re/post/show/3
    # https://konachan.com/post/show/270803/banishment-bicycle-grass-group-male-night-original
    in _, "post", "show", work_id, *rest
      @work_id = work_id

    # https://assets.yande.re/data/preview/7e/cf/7ecfdead705d7b956b26b1d37b98d089.jpg
    # https://konachan.com/data/preview/5d/63/5d633771614e4bf5c17df19a0f0f333f.jpg
    in _, "data", "preview", *subdirs, /^(\h{32})\.jpg$/
      @md5 = $1

    # https://yande.re/sample/ceb6a12e87945413a95b90fada406f91/.jpg
    # https://files.yande.re/sample/0d79447ce2c89138146f64ba93633568/yande.re%20290757%20sample%20seifuku%20thighhighs%20tsukudani_norio.jpg
    # https://konachan.com/sample/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20sample.jpg
    #
    # https://yande.re/jpeg/0c9ec0ffcaa40470093cb44c3fd40056/yande.re%2064649%20animal_ears%20cameltoe%20fixme%20nekomimi%20nipples%20ryohka%20school_swimsuit%20see_through%20shiraishi_nagomi%20suzuya%20swimsuits%20tail%20thighhighs.jpg
    # https://konachan.com/jpeg/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20banishment%20bicycle%20grass%20group%20male%20night%20original%20rooftop%20scenic%20signed%20stars%20tree.jpg
    #
    # https://yande.re/image/b4b1d11facd1700544554e4805d47bb6/.png
    # https://files.yande.re/image/2a5d1d688f565cb08a69ecf4e35017ab/yande.re%20349790%20breast_hold%20kurashima_tomoyasu%20mahouka_koukou_no_rettousei%20naked%20nipples.jpg
    # https://ayase.yande.re/image/2d0d229fd8465a325ee7686fcc7f75d2/yande.re%20192481%20animal_ears%20bunny_ears%20garter_belt%20headphones%20mitha%20stockings%20thighhighs.jpg
    # https://yuno.yande.re/image/1764b95ae99e1562854791c232e3444b/yande.re%20281544%20cameltoe%20erect_nipples%20fundoshi%20horns%20loli%20miyama-zero%20sarashi%20sling_bikini%20swimsuits.jpg
    # https://konachan.com/image/5d633771614e4bf5c17df19a0f0f333f/Konachan.com%20-%20270807%20black_hair%20bokuden%20clouds%20grass%20landscape%20long_hair%20original%20phone%20rope%20scenic%20seifuku%20skirt%20sky%20summer%20torii%20tree.jpg
    #
    # https://files.yande.re/image/e4c2ba38de88ff1640aaebff84c84e81/469784.jpg
    in _, ("sample" | "jpeg" | "image") => sample_type, /^\h{32}$/ => md5, file
      @md5 = md5
      @work_id = work_id_from_filename
      @original_file_ext = file_ext_for(sample_type)

    # https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg
    # https://files.yande.re/image/22577d2344fe694cf47f80563031b3cd.png
    # https://files.yande.re/sample/fb27a7ea6c48b2ef76fe915e378b9098.jpg
    in _, ("sample" | "jpeg" | "image") => sample_type, /^(\h{32})\.\w+$/
      @md5 = $1
      @original_file_ext = file_ext_for(sample_type)

    else
    end
  end

  def file_ext_for(sample_type)
    case sample_type
    when "image"
      file_ext
    when "jpeg"
      "png"
    end
  end

  def work_id_from_filename
    case CGI.unescape(filename).split
    # yande.re 290757 sample seifuku thighhighs tsukudani_norio
    # yande.re 290757
    in "yande.re", /^\d+$/ => work_id, *rest
      work_id

    # Konachan.com - 270803 sample
    in "Konachan.com", "-", /^\d+$/ => work_id, *rest
      work_id

    # 469784
    in [/^\d+$/ => work_id]
      work_id

    else
    end
  end

  def site_name
    case domain
    when "yande.re" then "Yande.re"
    when "konachan.com" then "Konachan"
    end
  end

  def self.preview_image_url(site_name, md5)
    case site_name
    when "Yande.re"
      "https://files.yande.re/data/preview/#{md5[0..1]}/#{md5[2..3]}/#{md5}.jpg"
    when "Konachan"
      "https://konachan.com/data/preview/#{md5[0..1]}/#{md5[2..3]}/#{md5}.jpg"
    end
  end

  def self.full_image_url(site_name, md5, file_ext, post_id = nil)
    case site_name
    when "Yande.re"
      file_host = "files.yande.re"
      filename_prefix = "yande.re%20"
    when "Konachan"
      file_host = "konachan.com"
      filename_prefix = "Konachan.com%20-%20"
    end

    # try to include the post_id so that it's saved for posterity in the canonical_url.
    if post_id.present?
      "https://#{file_host}/image/#{md5}/#{filename_prefix}#{post_id}.#{file_ext}"
    else
      "https://#{file_host}/image/#{md5}.#{file_ext}"
    end
  end
end
