# frozen_string_literal: true

class Source::URL::Tumblr < Source::URL
  attr_reader :work_id, :blog_name, :directory, :full_image_url

  def self.match?(url)
    url.domain == "tumblr.com"
  end

  def parse
    case [host, *path_segments]

    # https://66.media.tumblr.com/168dabd09d5ad69eb5fedcf94c45c31a/3dbfaec9b9e0c2e3-72/s640x960/bf33a1324f3f36d2dc64f011bfeab4867da62bc8.png
    # https://66.media.tumblr.com/5a2c3fe25c977e2281392752ab971c90/3dbfaec9b9e0c2e3-92/s500x750/4f92bbaaf95c0b4e7970e62b1d2e1415859dd659.png
    in _, *directories, /s\d+x\d+/ => dimensions, file if image_url?
      @directory = directories.first
      max_size = Integer.sqrt(Danbooru.config.max_image_resolution)
      @full_image_url = url.to_s.gsub(%r{/s\d+x\d+/\w+\.\w+\z}i, "/s#{max_size}x#{max_size}/#{file}")

    # http://data.tumblr.com/07e7bba538046b2b586433976290ee1f/tumblr_o3gg44HcOg1r9pi29o1_raw.jpg
    # https://40.media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_1280.jpg
    # https://media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_raw.jpg
    # https://66.media.tumblr.com/2c6f55531618b4335c67e29157f5c1fc/tumblr_pz4a44xdVj1ssucdno1_1280.png
    # https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif
    # https://media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_500.gif
    # https://66.media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_500h.png
    # https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.pnj
    in _, directory, file if image_url?
      @directory = directory
      parse_filename

    # https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
    # https://media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_1280.png
    # https://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_500.jpg
    # https://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg
    # https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4
    in _, file if image_url?
      parse_filename

    # https://marmaladica.tumblr.com/post/188237914346/saved
    # https://emlan.tumblr.com/post/189469423572/kuro-attempts-to-buy-a-racy-book-at-comiket-but
    # https://superboin.tumblr.com/post/141169066579/photoset_iframe/superboin/tumblr_o45miiAOts1u6rxu8/500/false
    # https://make-do5.tumblr.com/post/619663949657423872
    # http://raspdraws.tumblr.com/image/70021467381
    in _, ("post" | "image"), /^\d+$/ => work_id, *rest unless image_url?
      @blog_name = subdomain unless subdomain == "www"
      @work_id = work_id

    # https://tumblr.com/munespice/683613396085719040, new dashboard links
    in ("tumblr.com" | "www.tumblr.com"), blog_name, /^\d+$/ => work_id
      @blog_name = blog_name
      @work_id = work_id

    # https://www.tumblr.com/blog/view/artofelaineho/187614935612  # old dashboard links
    in ("www.tumblr.com" | "tumblr.com"), "blog", "view", blog_name, /^\d+$/ => work_id
      @blog_name = blog_name
      @work_id = work_id

    # https://www.tumblr.com/blog/view/artofelaineho
    # https://tumblr.com/blog/view/artofelaineho
    in ("www.tumblr.com" | "tumblr.com"), "blog", "view", blog_name
      @blog_name = blog_name

    # https://www.tumblr.com/blog/artofelaineho
    # http://tumblr.com/blog/kervalchan
    in ("www.tumblr.com" | "tumblr.com"), "blog", blog_name
      @blog_name = blog_name

    # https://www.tumblr.com/dashboard/blog/dankwartart
    # https://tumblr.com/dashboard/blog/dankwartart
    in ("www.tumblr.com" | "tumblr.com"), "dashboard", "blog", blog_name
      @blog_name = blog_name

    # https://rosarrie.tumblr.com/archive
    # https://solisnotte.tumblr.com/about
    # http://whereisnovember.tumblr.com/tagged/art
    in _, *rest unless image_url? || subdomain == "www"
      @blog_name = subdomain

    else
      nil
    end
  end

  def parse_filename
    return if filename.blank?

    case filename.split("_")

    # http://data.tumblr.com/07e7bba538046b2b586433976290ee1f/tumblr_o3gg44HcOg1r9pi29o1_raw.jpg
    # https://40.media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_1280.jpg
    # https://media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_raw.jpg
    # https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif
    # https://media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_500.gif
    # https://66.media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_500h.png
    # https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.pnj
    # https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png
    # https://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_500.jpg
    in *words, /\A\d+h?|raw\z/ => size
      @filename = words.join("_")
      @sample_size = size

    # https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4
    # https://66.media.tumblr.com/168dabd09d5ad69eb5fedcf94c45c31a/3dbfaec9b9e0c2e3-72/s640x960/bf33a1324f3f36d2dc64f011bfeab4867da62bc8.png
    # https://66.media.tumblr.com/5a2c3fe25c977e2281392752ab971c90/3dbfaec9b9e0c2e3-92/s500x750/4f92bbaaf95c0b4e7970e62b1d2e1415859dd659.png
    else
      @filename = filename
      @sample_size = nil
    end
  end

  def image_url?
    # http://data.tumblr.com/07e7bba538046b2b586433976290ee1f/tumblr_o3gg44HcOg1r9pi29o1_raw.jpg
    # https://40.media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_1280.jpg
    # https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4
    subdomain&.ends_with?(".media") || subdomain&.in?(%w[data media])
  end

  def variants
    return [] unless @sample_size.present? && @filename.present?
    directory = "#{@directory}/" if @directory.present?

    sizes = %w[1280 640 540 500h 500 400 250 100]
    sizes.map { |size| "https://media.tumblr.com/#{directory}#{@filename}_#{size}.#{file_ext}" }
  end

  def page_url
    "https://#{blog_name}.tumblr.com/post/#{work_id}" if blog_name.present? && work_id.present?
  end

  def profile_url
    "https://#{blog_name}.tumblr.com" if blog_name.present?
  end
end
