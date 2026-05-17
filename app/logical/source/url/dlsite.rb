# frozen_string_literal: true

# @see Source::URL::CiEn
class Source::URL::Dlsite < Source::URL
  site "DLsite", url: "https://www.dlsite.com", domains: %w[dlsite.com dlsite.net dlsite.jp]

  attr_reader :category, :work_type, :product_id, :maker_id, :author_id

  def self.match?(url)
    url.domain.in?(%w[dlsite.com dlsite.net dlsite.jp]) && url.host != "ci-en.dlsite.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://img.dlsite.jp/modpub/images2/work/doujin/RJ01183000/RJ01182574_img_main.jpg
    # https://img.dlsite.jp/modpub/images2/ana/doujin/RJ01571000/RJ01570715_ana_img_main.webp
    in "img", "dlsite.jp", "modpub", "images2", ("work" | "ana") => work_type, "doujin", _, /^([A-Z]+\d+)/
      @work_type = (work_type == "ana") ? "announce" : "work"
      @product_id = $1

    # https://img.dlsite.jp/modpub/images2/parts/RJ01109000/RJ01108646/c595ec4d121d80c300d94b368806d655.jpg
    # https://img.dlsite.jp/modpub/images2/parts_ana/RJ01030000/RJ01029765/33415f94d0cf83d85f39624dac1e3724.jpg
    in "img", "dlsite.jp", "modpub", "images2", /parts/ => work_type, _, product_id, _
      @work_type = work_type.include?("ana") ? "announce" : "work"
      @product_id = product_id

    # https://www.dlsite.com/home/work/=/product_id/RJ01096697
    # https://www.dlsite.com/home/work/=/product_id/RJ01096697.html
    # https://www.dlsite.com/maniax/work/=/product_id/RJ01134569.html
    # https://www.dlsite.com/maniax/announce/=/product_id/RJ01137148.html
    # https://www.dlsite.com/maniax-touch/announce/=/product_id/RJ01110853.html
    # https://www.dlsite.com/girls/work/=/product_id/RJ01345621.html
    # https://www.dlsite.com/bl/work/=/product_id/RJ01329452.html
    # https://www.dlsite.com/pro/work/=/product_id/VJ015443.html
    # https://www.dlsite.com/books/work/=/product_id/BJ181344.html
    # https://www.dlsite.com/eng/work/=/product_id/RE277378.html
    # https://www.dlsite.com/ecchi-eng/work/=/product_id/RE028506.html
    # https://www.dlsite.com/ecchi-eng-touch/work/=/product_id/RE166667.html
    # https://www.dlsite.com/ecchi-eng/announce/=/product_id/RE155768.html
    in _, "dlsite.com", category, ("work" | "announce") => work_type, "=", "product_id", product_id
      @category = category
      @work_type = work_type
      @product_id = product_id.delete_suffix(".html")

    # https://eng.dlsite.com/work/=/product_id/RE036764
    # https://eng.dlsite.com/work/=/product_id/RE022725.html
    # http://maniax.dlsite.com/work/=/product_id/RJ072689.html
    in _, "dlsite.com", "work" => work_type, "=", "product_id", product_id
      @category = "maniax"
      @work_type = work_type
      @product_id = product_id.delete_suffix(".html")

    # https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689
    # https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689.html
    # https://www.dlsite.com/maniax-touch/circle/profile/=/maker_id/RG64022.html
    # https://www.dlsite.com/home/circle/profile/=/maker_id/RG64308.html
    # https://www.dlsite.com/ecchi-eng/circle/profile/=/maker_id/RG05689.html
    # https://www.dlsite.com/girls/circle/profile/=/maker_id/RG70492.html
    # https://www.dlsite.com/bl/circle/profile/=/maker_id/RG11630.html
    in _, "dlsite.com", category, "circle", "profile", "=", "maker_id", maker_id
      @category = category
      @maker_id = maker_id.delete_suffix(".html")

    # https://www.dlsite.com/books/author/=/author_id/AJ010529
    # https://www.dlsite.com/comic/author/=/author_id/AJ010529
    # https://www.dlsite.com/maniax/author/=/author_id/AJ010452
    in _, "dlsite.com", category, "author", "=", "author_id", author_id
      @category = category
      @author_id = author_id

    # https://www.dlsite.com/maniax/fsr/=/keyword_creater/"すーぱーなごやか"
    # https://dlsite.blogimg.jp/RG09732/imgs/1/3/13f3008e.jpg
    # https://dlsite.blogimg.jp/RG09732/imgs/e/8/e8e6579e.jpg
    # https://media.dlsite.com/chobit/contents/0907/ckn20nx8gbsos4g408kgk0sk0/ckn20nx8gbsos4g408kgk0sk0_020.jpg
    # https://ch.dlsite.com/profile/209312/timeline
    # http://b.dlsite.net/RG05689/
    # http://b.dlsite.net/RG09732/archives/51808651.html
    else
      nil
    end
  end

  def page_url
    if category.present? && work_type.present? && product_id.present?
      "https://www.dlsite.com/#{category}/#{work_type}/=/product_id/#{product_id}.html"
    elsif work_type.present? && product_id.present?
      "https://www.dlsite.com/maniax/#{work_type}/=/product_id/#{product_id}.html"
    end
  end

  def profile_url
    if maker_id.present?
      "https://www.dlsite.com/maniax/circle/profile/=/maker_id/#{maker_id}.html"
    elsif author_id.present?
      "https://www.dlsite.com/books/author/=/author_id/#{author_id}"
    end
  end
end
