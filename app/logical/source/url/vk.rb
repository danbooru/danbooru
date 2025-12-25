# frozen_string_literal: true

class Source::URL::Vk < Source::URL
  RESERVED_USERNAMES = %w[about audio blog clips games groups feed jobs join legal login mobile products technology services terms video]
  PAGE_TYPES = %w[album albums audio audios clip club doc event id market page photo post product public topic uslugi video videos wall wpt]
  ID_REGEX = /^(#{Regexp.union(PAGE_TYPES)})(-?\d+)(?:_(\d+))?/ # wall-111670353_64474

  attr_reader :full_image_url, :username, :page_type, :id, :owner_id, :item_id, :parent_id, :parent_owner_id, :parent_item_id, :article_slug, :doc_hash

  def self.match?(url)
    url.domain.in?(%w[vk.com vk.cc vk.me vk.ru vk.team vk.company vkontakte.ru mvk.com userapi.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://sun9-69.userapi.com/impg/VJBWV0vYZJLRhFBkQxaVtVo9_givXP6BycJJow/RBoOQ0nHMNc.jpg?size=1200x1600&quality=96&sign=73e562b2f74629cba714f7a348d0e815&type=album
    # https://sun9-69.userapi.com/VJBWV0vYZJLRhFBkQxaVtVo9_givXP6BycJJow/RBoOQ0nHMNc.jpg (full)
    # https://sun9-20.userapi.com/impf/c836729/v836729326/1f25a/N3g5QzPZBbM.jpg?size=800x800&quality=96&sign=06bcfc21a2980b0ff1f59129a25c0ceb&type=album (sample)
    # https://sun9-20.userapi.com/c836729/v836729326/1f25a/N3g5QzPZBbM.jpg (full)
    in _, "userapi.com", ("impf" | "impg"), *subdirs, file
      @full_image_url = "https://pp.userapi.com/#{subdirs.join("/")}/#{file}"

    # http://sun4.dataix-kz-akkol.userapi.com/c854320/v854320725/772f0/W3F-BmEDE5c.jpg (redirects to https://pp.userapi.com/c854320/v854320725/772f0/W3F-BmEDE5c.jpg)
    # https://sun9-55.userapi.com/c235131/u495199190/d59/-3/y_1029db78fe.jpg (sample)
    # https://psv4.userapi.com/c235131/u495199190/docs/d59/b94c28ecfbf7/Strakh_Pakhnet_Lyubovyu.png?extra=mZ9zdTdOqm0QPKfsJ8msJr5XMKqxvfSiQNZHBjCceMvuMmxeJiE_bTi12ZXc66HkriH02LKY4aq7tQQh-suMtdtaNYXUNe49sgrS8m3M02eUnwjXzATQ3oHWqB0iuPqfMcmj3uQqmjwsNlc (full)
    in /^(sun|psv)/, "userapi.com", *rest
      @full_image_url = "https://pp.userapi.com#{path}"

    # The `z` param opens the page in an overlay over the current page.
    # https://vk.com/sgips?z=album-111670353_227001377
    # https://vk.com/sgips?z=photo-111670353_457285023%2Fwall-111670353_64279
    # https://vk.com/the.dark.mangaka?z=video-162468097_456239018%2Fvideos-162468097%2Fpl_-162468097_-2
    # https://vk.com/wall-143305139_11128?z=photo-143305139_457245182%2Fwall-143305139_11133
    in _, "vk.com", id if params[:z].present?
      @username = id unless id.match?(ID_REGEX)

      # https://vk.com/wall-143305139_11128?z=photo-143305139_457245182%2Fwall-143305139_11133
      if params[:z].include?("/")
        item, owner = params[:z].split("/")
        @id, @page_type, @owner_id, @item_id = parse_id(item)
        @parent_id, @parent_page_type, @parent_owner_id, @parent_item_id = parse_id(owner)
      # https://vk.com/sgips?z=album-111670353_227001377
      else
        @id, @page_type, @owner_id, @item_id = parse_id(params[:z])
      end

    # The `w` param opens the page in an overlay over a given page (but only works on certain pages).
    # https://vk.com/market-111670353?w=product-111670353_9110906
    # https://vk.com/uslugi-191516762?w=product-191516762_8422820
    # https://vk.com/public191516762?w=wall-191516762_2283
    in _, "vk.com", ID_REGEX if params[:w].present?
      @id, @page_type, @owner_id, @item_id = parse_id(params[:w])

    # https://vk.com/wall-111670353 (wall for https://vk.com/sgips)
    # https://vk.com/wall-111670353_64474 (public post)
    # https://vk.com/wall194141788_4201 (not public post)
    # https://vk.com/wall-111670353_64467?reply=64470 (comment)
    # https://vk.com/wall-111670353_64467?reply=64471&thread=64470 (reply to comment)
    # https://vk.com/albums-111670353
    # https://vk.com/album-111670353_00
    # https://vk.com/album-111670353_227001377
    # https://vk.com/audios-143305139
    # https://vk.com/board111670353
    # https://vk.com/clip-111670353_456239067
    # https://vk.com/club111670353 (same as https://vk.com/sgips)
    # https://vk.com/docs-111670353
    # https://vk.com/doc-111670353_502376172?hash=TTii3BdlGkIC4jg5gogivpeGzfVnO641Tm1XojRZ5yk (pdf)
    # https://m.vk.com/doc-111670353_502376172?hash=TTii3BdlGkIC4jg5gogivpeGzfVnO641Tm1XojRZ5yk (redirects to file)
    # https://vk.com/doc229501313_486829055?hash=agknDJULhcUcAKZILf2E2ceEsVm7ZswUT5biPKKNzVH (private)
    # https://vk.com/photos-111670353
    # https://vk.com/photo-111670353_457284649
    # https://vk.com/photo-185765571_457240497?list=album-185765571_00
    # https://m.vk.com/photo-143305139_457245182?list=wall-143305139_11133 (photo isn't viewable without list param)
    # https://vk.com/topic-111670353_39809212?post=17
    # https://vk.com/videos-111670353 (redirects to https://vk.com/video/@sgips)
    # https://vk.com/video-111670353_456239068
    # https://vk.com/id194141788
    in _, "vk.com", ID_REGEX => id
      @doc_hash = params[:hash]
      @id, @page_type, @owner_id, @item_id = parse_id(id)
      @parent_id, @parent_page_type, @parent_owner_id, @parent_item_id = parse_id(params[:list]) if params[:list]&.match?(ID_REGEX)

    # https://vk.com/@sgips
    # https://vk.com/@sgips-tri-istorii-o-lovce
    in _, "vk.com", /^@/ => username
      @username, _, @article_slug = username.partition("-")

    # https://vk.com/video/@sgips
    in _, "vk.com", "video", /^@/ => username
      @username = username.delete_prefix("@")

    # https://vk.com/clips/sgips
    in _, "vk.com", "clips", username
      @username = username

    # https://vk.com/enigmasblog
    # https://vk.com/enigmasblog/Fullart (tag search)
    # https://vk.com/enigmasblog?w=wall-185765571_2636
    in _, "vk.com", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username
      @id, @page_type, @owner_id, @item_id = parse_id(params[:w]) if params[:w].present?

    # https://vk.com/feed?section=search&q=%23Pixelart
    # https://vk.com/video?section=tagged&id=46468795637
    # http://vk.com/video?gid=41589556
    # https://api.vk.com/method/resolveScreenName?screen_name=enigmasblog
    # https://pp.userapi.com/SFtQSP8RF92dcbLyyfNEYnO20jfk5j-PTCUowA/L2iA1s92-js.jpg
    # http://cs417130.userapi.com/v417130351/1a8d/TjGqu69wdng.jpg (redirects to https://pp.userapi.com/46cFjNjezaoygOsETd7EqY4WEvcyoPKOgPFT4A/4czZT5Mw_T8.jpg)
    else
      nil
    end
  end

  def parse_id(id)
    id.match(ID_REGEX).to_a
  end

  def wall_id
    owner_id if page_type == "wall"
  end

  def mobile_url
    if id.present? && parent_id.present?
      "https://m.vk.com/#{id}?list=#{parent_id}"
    elsif id.present? && doc_hash.present?
      "https://m.vk.com/#{id}?hash=#{doc_hash}"
    elsif id.present?
      "https://m.vk.com/#{id}"
    end
  end

  def page_url
    if username.present? && article_slug.present?
      "https://vk.com/@#{username}-#{article_slug}"
    elsif id.present? && parent_id.present?
      "https://vk.com/?z=#{id}/#{parent_id}"
    elsif id.present? && item_id.present?
      "https://vk.com/#{id}"
    end
  end

  def profile_url
    if username.present?
      "https://vk.com/#{username}"
    elsif page_type == "id"
      "https://vk.com/#{id}"
    elsif owner_id.present?
      "https://vk.com/wall#{owner_id}"
    end
  end
end
