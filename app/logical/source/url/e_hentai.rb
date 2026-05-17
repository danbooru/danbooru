# frozen_string_literal: true

class Source::URL::EHentai < Source::URL
  site "E-Hentai", url: "https://e-hentai.org", domains: %w[e-hentai.org exhentai.org hath.network ehtracker.org exhentai55ld2wyap5juskbm67czulomrouspdacjamjeloj7ugjbsad.onion]

  attr_reader :image_params, :image_sample, :gallery_id, :gallery_token, :gallery_page, :page_number, :page_token

  def self.match?(url)
    url.domain.in?(%w[e-hentai.org exhentai.org hath.network ehtracker.org exhentai55ld2wyap5juskbm67czulomrouspdacjamjeloj7ugjbsad.onion])
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://lyjrkow.ksxjubvoouva.hath.network/h/416a7c19fb25549e084876f932e2f6d45a5b2d63-1215161-2400-3589-jpg/keystamp=1683990600-aab6e15ff8;fileindex=119976531;xres=2400/89931055_p0.jpg
    # https://drjvktq.miqlthdkffuu.hath.network/h/dce4b9677c8f769c12c8889e2581b989a3edd1bb-280532-642-802-png/keystamp=1683992100-6e1bddc318;fileindex=116114230;xres=org/1667196644017_fe0ug7p4.png
    in _, "hath.network", "h", _, params_string, _
      @image_params = params_string.split(";").to_h { it.split("=", 2) }.with_indifferent_access
      @image_sample = image_params[:xres] != "org"

    # https://hacaqjfrpvthigkeomjq.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/b09e528c8897a5a0ecb288f85fe9e9230d4a5f1c-483531-1280-1914-jpg/1280/v2f1fil8ij9dbk115c6/89931055_p0.jpg
    # https://ykofnavysaepqurqrbmv.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/x/0/cqq6hb0kct3sx4115c4/89931055_p0.jpg
    # https://kitztqqrsr.hath.network/om/118110641/05c19376ef2e1a56e8b5dbbe97209ca11880c946-4635509-2378-3375-png/x/0/3dtbckd27vd3zu1x8w1/kitikuourance_shokaibon_139.png
    in _, "hath.network", "om", _key, _, _, sample_size, _, _
      @image_sample = sample_size != "0"

    # https://e-hentai.org/fullimg/2403312/138/0g1swt6ak73/kitikuourance_shokaibon_139.png (full, redirects to below)
    # * https://kitztqqrsr.hath.network/om/118110641/05c19376ef2e1a56e8b5dbbe97209ca11880c946-4635509-2378-3375-png/x/0/3dtbckd27vd3zu1x8w1/kitikuourance_shokaibon_139.png (full)
    # * https://doxcdvs.ioyswsmoxrrb.hath.network:1024/h/b9f77fdd551e9ea9bb45ed18e4cd71cb03ec9a58-280138-1280-1817-wbp/keystamp=1773846900-053d91d63b;fileindex=118110641;xres=1280/kitikuourance_shokaibon_139.webp (sample, keystamp changes every time)
    # * https://e-hentai.org/s/05c19376ef/2403312-138 (page)
    # * https://e-hentai.org/g/2403312/71ee3b71d3/?p=6 (gallery)
    in _, _, "fullimg", /^\d+$/ => gallery_id, /^\d+$/ => page_number, _, _
      @gallery_id = gallery_id
      @page_number = page_number

    # https://exhentai.org/s/6fd82f0d38/2403312-135
    # https://e-hentai.org/s/75c803851b/2403312-136
    in _, _, "s", /^\h+$/ => page_token, /^\d+-\d+$/ => file
      @page_token = page_token
      @gallery_id, @page_number = file.split("-", 2)

    # https://e-hentai.org/g/2403312/71ee3b71d3
    # https://e-hentai.org/g/2403312/71ee3b71d3/?p=6
    in _, _, "g", /^\d+$/ => gallery_id, /^\h+$/ => gallery_token
      @gallery_id = gallery_id
      @gallery_token = gallery_token
      @gallery_page = params[:p]

    # https://e-hentai.org/r/b9f77fdd551e9ea9bb45ed18e4cd71cb03ec9a58-280138-1280-1817-wbp/forumtoken/2403312-138/kitikuourance_shokaibon_139.webp
    in _, _, "r", /^\h{40}-\d+-\d+-\d+-\w+$/ => _image_hash, "forumtoken", /^\d+-\d+$/ => gallery_and_page, _file
      @gallery_id, @page_number = gallery_and_page.split("-", 2)

    # https://e-hentai.org/archiver.php?gid=2403312&token=71ee3b71d3
    in _, _, ("archiver.php" | "gallerytorrents.php") if params[:gid].present? && params[:token].present?
      @gallery_id = params[:gid]
      @gallery_token = params[:token]

    # https://e-hentai.org/gallerytorrents.php?gid=2403312&t=71ee3b71d3
    in _, _, "gallerytorrents.php" if params[:gid].present? && params[:t].present?
      @gallery_id = params[:gid]
      @gallery_token = params[:t]

    # https://ehtracker.org/get/2403312/485532c1cfa3b686556edf8e3906005535cc216a.torrent (redistributable torrent)
    in _, "ehtracker.org", "get", /^\d+$/ => gallery_id, _
      @gallery_id = gallery_id

    # https://encvgvvzml.hath.network/archive/2403312/bf6b45ab72cad9e8a097b3add23f9e38a9062697/e35dpycak73/1
    in _, "hath.network", "archive", /^\d+$/ => gallery_id, /^\h{40}$/, _, _
      @gallery_id = gallery_id

    # https://e-hentai.org/?f_shash=05c19376ef2e1a56e8b5dbbe97209ca11880c946&fs_from=kitikuourance_shokaibon_139.png+from+Kichikuou+Rance+First+Press+Release+Book
    # https://e-hentai.org/tag/artist:spirale
    # https://e-hentai.org/uploader/Spirale
    else
      nil
    end
  end

  def page_url
    if gallery_id.present? && page_token.present? && page_number.present?
      "https://#{normalized_domain}/s/#{page_token}/#{gallery_id}-#{page_number}"
    elsif gallery_id.present? && gallery_token.present?
      "https://#{normalized_domain}/g/#{gallery_id}/#{gallery_token}"
    end
  end

  def bad_source?
    # https://e-hentai.org/s/75c803851b/2403312-136 is good, https://e-hentai.org/g/2403312/71ee3b71d3 is bad
    !(gallery_id.present? && page_token.present? && page_number.present?)
  end

  def image_sample?
    image_sample
  end

  def normalized_domain
    (domain == "exhentai55ld2wyap5juskbm67czulomrouspdacjamjeloj7ugjbsad.onion") ? "exhentai.org" : domain
  end
end
