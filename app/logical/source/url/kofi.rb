# frozen_string_literal: true

# @see Source::Extractor::Kofi
class Source::URL::Kofi < Source::URL
  RESERVED_USERNAMES = %w[c i s about account album cdn commissions discord explore gallery gold memberships post privacy shop terms]

  attr_reader :full_image_url, :username, :user_id, :gallery_item_id, :shop_item_id, :commission_id, :post_id, :album_id, :slug

  def self.match?(url)
    url.domain == "ko-fi.com" || url.host == "az743702.vo.msecnd.net"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://storage.ko-fi.com/cdn/useruploads/post/2c42fc4c-6ebb-4b09-9da0-d14b19a105b1_d69ed1ef-bb4c-4c9f-96ed-4cac35ab8c0d.png (sample)
    # https://storage.ko-fi.com/cdn/useruploads/display/2c42fc4c-6ebb-4b09-9da0-d14b19a105b1_d69ed1ef-bb4c-4c9f-96ed-4cac35ab8c0d.png (full; page: https://ko-fi.com/i/IU7U5SS0YZ)
    #
    # https://storage.ko-fi.com/cdn/useruploads/post/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png (sample; 480x433)
    # https://storage.ko-fi.com/cdn/useruploads/display/6132206b-945b-42e9-8326-b4de510bb1da_ilustraci%C3%B3n9_2.png (sample; 780x704)
    # https://storage.ko-fi.com/cdn/useruploads/93b977cb-22ed-45c1-86ad-2655e0b7d068_ilustraci%C3%B3n9_2.png (full; 3493x3151; page: https://ko-fi.com/i/IT6T0N4D36)
    #
    # https://storage.ko-fi.com/cdn/useruploads/display/PNG_4d7caae0-af23-40cd-b1f7-75deda8027dd.PNG (commission)
    in _, _, "cdn", "useruploads", ("post" | "display"), file
      @full_image_url = "https://storage.ko-fi.com/cdn/useruploads/display/#{file}"

    # https://storage.ko-fi.com/cdn/useruploads/png_bec82915-ce70-4fea-a386-608a6afb1b33cover.jpg?v=f2fcf155-8d71-4a7d-a91a-0fbdec814684 (profile banner)
    # https://cdn.ko-fi.com/cdn/useruploads/e53090ad-734d-4c1c-ab15-73215be79804_tiny.png
    # https://az743702.vo.msecnd.net/cdn/useruploads/tiny_dfc72789-50bf-486f-9a87-81d05ee09437.jpg
    in _, _, "cdn", *rest
      nil

    # https://ko-fi.com/i/IU7U5SS0YZ
    in _, "ko-fi.com", "i", gallery_item_id
      @gallery_item_id = gallery_item_id

    # https://ko-fi.com/s/5fc8f89b6e
    in _, "ko-fi.com", "s", shop_item_id
      @shop_item_id = shop_item_id

    # https://ko-fi.com/c/780f9a88f9
    in _, "ko-fi.com", "c", commission_id
      @commission_id = commission_id

    # https://ko-fi.com/post/Hooligans-Update-3-May-30th-2024-S6S0YPT5K
    in _, "ko-fi.com", "post", slug
      @slug, _, @post_id = slug.rpartition("-")

    # https://ko-fi.com/album/Original-Artworks-Q5Q2JPOWH
    in _, "ko-fi.com", "album", slug
      @slug, _, @album_id = slug.rpartition("-")

    # https://ko-fi.com/Gallery/LockedGalleryItem?id=IV7V6XDSRU#checkoutModal
    in _, "ko-fi.com", "Gallery", "LockedGalleryItem"
      @gallery_item_id = params[:id]

    # https://ko-fi.com/E1E7FH8ZY?viewimage=IU7U5SS0YZ
    # https://ko-fi.com/T6T41FDFF/gallery/?action=gallery
    in _, "ko-fi.com", /^[A-Z0-9]{9}$/ => user_id, *rest
      @user_id = user_id
      @gallery_item_id = params[:viewimage]

    # https://ko-fi.com/johndaivid
    # https://ko-fi.com/thom_sketching/gallery?viewimage=IO5O1BOYV6#galleryItemView
    # https://ko-fi.com/thom_sketching/commissions?commissionAlias=780f9a88f9&amp;openCommissionsMenu=True#buyShopCommissionModal
    in _, "ko-fi.com", username, *rest unless username&.downcase.in?(RESERVED_USERNAMES)
      @username = username
      @gallery_item_id = params[:viewimage]
      @commission_id = params[:commissionAlias]

    else
      nil
    end
  end

  def site_name
    "Ko-fi"
  end

  def extractor_class
    if gallery_item_id.present?
      Source::Extractor::KofiGalleryItem
    elsif shop_item_id.present?
      Source::Extractor::KofiShopItem
    elsif commission_id.present?
      Source::Extractor::KofiCommission
    elsif post_id.present?
      Source::Extractor::KofiPost
    else
      Source::Extractor::Kofi
    end
  end

  def page_url
    if username.present? && gallery_item_id.present?
      "https://ko-fi.com/#{username}?viewimage=#{gallery_item_id}"
    elsif user_id.present? && gallery_item_id.present?
      "https://ko-fi.com/#{user_id}?viewimage=#{gallery_item_id}"
    elsif gallery_item_id.present?
      "https://ko-fi.com/i/#{gallery_item_id}"
    elsif shop_item_id.present?
      "https://ko-fi.com/s/#{shop_item_id}"
    elsif commission_id.present?
      "https://ko-fi.com/c/#{commission_id}"
    elsif post_id.present?
      "https://ko-fi.com/post/#{slug}-#{post_id}" if slug.present? && post_id.present?
    elsif album_id.present?
      "https://ko-fi.com/album/#{slug}-#{album_id}" if slug.present? && album_id.present?
    end
  end

  def profile_url
    if username.present?
      "https://ko-fi.com/#{username}"
    elsif user_id.present?
      "https://ko-fi.com/#{user_id}"
    end
  end
end
