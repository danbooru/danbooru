# frozen_string_literal: true

# Skima has two sites: the Japanese site at skima.jp, and the international site at commission.skima.jp (formerly
# wskima.com). Both sites share the same users, commissions, and pre-made illustrations ("dl products"), but each site
# only shows some of them.
class Source::URL::Skima < Source::URL
  site "Skima", url: "https://skima.jp", domains: %w[skima.jp wskima.com]

  attr_reader :gallery_id, :item_id, :dl_product_id, :user_id, :image_id, :full_image_url, :candidate_full_image_urls

  def self.match?(url)
    url.domain.in?(%w[skima.jp wskima.com])
  end

  def parse
    # Remove the locale from e.g. https://commission.skima.jp/en/pre-made-illustration/detail/256160.
    segments = (international? && path_segments.first.to_s.match?(/\A[a-z]{2}(-[a-zA-Z]+)?\z/)) ? path_segments.drop(1) : path_segments

    case [subdomain, domain, *segments]

    # https://cdn-gallery.skima.jp/gallery/017/284/17284/detail-e2ff46808671c188aba936b55038db1b-20171226132800.jpeg (sample)
    # https://cdn-gallery.skima.jp/gallery/055/208/55208/tip-f0081762dcb72ab22241526cbc00c814-20190215093719.jpeg (sample)
    #
    # Gallery samples have a different hash than the full image, so they can't be converted to full image URLs. The
    # sample and the full image have the same image ID (17284) though.
    in "cdn-gallery", "skima.jp", "gallery", /\A\d+\z/, /\A\d+\z/, /\A\d+\z/ => image_id, /\A[a-z]+-/
      @image_id = image_id

    # https://cdn-gallery.skima.jp/gallery/017/284/17284/d1905510dbb435ce81cc4056c32055d8-20171226132800.jpeg (full)
    in "cdn-gallery", "skima.jp", "gallery", /\A\d+\z/, /\A\d+\z/, /\A\d+\z/ => image_id, _
      @image_id = image_id
      @full_image_url = without(:query).to_s

    # https://cdn-common.skima.jp/item/472/833/1472833/showcase-9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg (sample)
    # https://cdn-common.skima.jp/item/181/491/1181491/thumbnail-decd257745cc6e1a06af3df899c019f2-20230112232332.jpeg (sample)
    # https://cdn-common.skima.jp/item/875/376/1875376/timeline-6218f03c65fb9113b5e4d876ef332521-20260607185215.jpeg (sample)
    # https://cdn-common.skima.jp/dlsample/294/329/2294329/thumbnail-41c5e0f2f64bd224785f5bb352f4f420-20240601221013.jpeg (sample)
    # https://cdn-common.skima.jp/profile/067/007/67007/large-61a8a2b43e63f24bb9cfe989d8d0d942-20191204225002.jpeg (sample)
    # https://cdn-common.skima.jp/profcover/074/536/74536/thumbnail-70135caaca056b9506f4a22457f05b03-20240609020637.jpeg (sample)
    #
    # The sample's extension is always .jpeg, but the original's isn't. Commission originals are always .jpeg, .png, or
    # .gif. Adoptable originals keep the extension of the uploaded file, so they can also be .jpg or uppercase, like .PNG.
    in "cdn-common", "skima.jp", ("item" | "dlsample" | "profile" | "profcover") => type, /\A\d+\z/ => a, /\A\d+\z/ => b, /\A\d+\z/ => c, /\A[a-z]+-(\h+-\d+)\.\w+\z/
      hash = $1
      @image_id = c
      extensions = (type == "item") ? %w[jpeg png gif] : %w[png jpg jpeg PNG]
      @candidate_full_image_urls = extensions.map do |ext|
        "https://cdn-common.skima.jp/#{type}/#{a}/#{b}/#{c}/#{hash}.#{ext}"
      end

    # https://cdn-common.skima.jp/item/472/833/1472833/9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg (full)
    # https://cdn-common.skima.jp/dlsample/294/329/2294329/41c5e0f2f64bd224785f5bb352f4f420-20240601221013.png (full, watermarked)
    # https://cdn-common.skima.jp/profile/067/007/67007/61a8a2b43e63f24bb9cfe989d8d0d942-20191204225002.png (full)
    in "cdn-common", "skima.jp", ("item" | "dlsample" | "profile" | "profcover"), /\A\d+\z/, /\A\d+\z/, /\A\d+\z/ => image_id, /\A\h+-\d+\.\w+\z/
      @image_id = image_id
      @full_image_url = without(:query).to_s

    # https://skima.jp/gallery?id=6428
    in _, "skima.jp", "gallery" if params[:id].to_s.match?(/\A\d+\z/)
      @gallery_id = params[:id]

    # https://skima.jp/item/detail?item_id=169712
    in _, "skima.jp", "item", "detail" if params[:item_id].to_s.match?(/\A\d+\z/)
      @item_id = params[:item_id]

    # https://skima.jp/dl/detail?id=260834
    in _, "skima.jp", "dl", "detail" if params[:id].to_s.match?(/\A\d+\z/)
      @dl_product_id = params[:id]

    # https://skima.jp/profile?id=1927
    # https://skima.jp/profile/galleries?id=1927
    # https://skima.jp/profile/commissions?id=1927
    # https://skima.jp/profile/dl_products?id=1927
    # https://skima.jp/profile/reviews?id=1927
    in _, "skima.jp", "profile", *rest if params[:id].to_s.match?(/\A\d+\z/) && rest.size <= 1
      @user_id = params[:id]

    # https://skima.jp/u/id21469/ (redirects to https://skima.jp/profile?id=21469)
    in _, "skima.jp", "u", /\Aid(\d+)\z/
      @user_id = $1

    # https://commission.skima.jp/en/commission/detail/307121
    in "commission", "skima.jp", "commission", "detail", /\A\d+\z/ => item_id
      @item_id = item_id

    # https://commission.skima.jp/en/pre-made-illustration/detail/256160
    in "commission", "skima.jp", "pre-made-illustration", "detail", /\A\d+\z/ => dl_product_id
      @dl_product_id = dl_product_id

    # https://commission.skima.jp/en/items/256160 (redirects to https://commission.skima.jp/en/pre-made-illustration/detail/256160)
    # https://wskima.com/items/256160 (redirects to https://commission.skima.jp/en/items/256160)
    in _, ("skima.jp" | "wskima.com"), "items", /\A\d+\z/ => dl_product_id if international?
      @dl_product_id = dl_product_id

    # https://commission.skima.jp/en/creator/294451
    # https://commission.skima.jp/en/profile/294451
    # https://wskima.com/creator/294451
    in _, ("skima.jp" | "wskima.com"), ("creator" | "profile"), /\A\d+\z/ => user_id if international?
      @user_id = user_id

    else
      nil
    end
  end

  # @return [Boolean] True if this is a URL for the international site (commission.skima.jp or wskima.com).
  def international?
    subdomain == "commission" || domain == "wskima.com"
  end

  def image_url?
    subdomain.in?(%w[cdn-gallery cdn-common])
  end

  def image_sample?
    image_url? && full_image_url.nil?
  end

  def page_url
    if gallery_id.present?
      "https://skima.jp/gallery?id=#{gallery_id}"
    elsif item_id.present? && international?
      "https://commission.skima.jp/commission/detail/#{item_id}"
    elsif item_id.present?
      "https://skima.jp/item/detail?item_id=#{item_id}"
    elsif dl_product_id.present? && international?
      "https://commission.skima.jp/pre-made-illustration/detail/#{dl_product_id}"
    elsif dl_product_id.present?
      "https://skima.jp/dl/detail?id=#{dl_product_id}"
    end
  end

  def profile_url
    "https://skima.jp/profile?id=#{user_id}" if user_id.present?
  end
end
