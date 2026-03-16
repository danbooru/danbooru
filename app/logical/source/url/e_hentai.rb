# frozen_string_literal: true

class Source::URL::EHentai < Source::URL
  site "E-Hentai", url: "https://e-hentai.org", domains: %w[e-hentai.org exhentai.org hath.network]

  attr_reader :image_params, :image_sample

  def self.match?(url)
    url.domain.in?(%w[e-hentai.org exhentai.org hath.network])
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
    in _, "hath.network", "om", _key, _, _, sample_size, _, _
      @image_sample = sample_size != "0"

    # https://e-hentai.org/tag/artist:spirale
    # https://e-hentai.org/uploader/Spirale
    else
      nil
    end
  end

  def site_name
    "E-Hentai"
  end

  def image_sample?
    image_sample
  end
end
