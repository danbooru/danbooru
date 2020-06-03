class NicoSeigaApiClient
  extend Memoist
  XML_API = "https://seiga.nicovideo.jp/api"

  def initialize(work_id:, type:)
    @work_id = work_id
    @work_type = type
  end

  def image_ids
    if @work_type == "illust"
      [api_response["id"]]
    elsif @work_type == "manga"
      manga_api_response.map do |x|
        case x["meta"]["source_url"]
        when %r{/thumb/(\d+)\w}i then Regexp.last_match(1)
        when %r{nicoseiga\.cdn\.nimg\.jp/drm/image/\w+/(\d+)\w}i then Regexp.last_match(1)
        end
      end
    end
  end

  def title
    api_response["title"]
  end

  def description
    api_response["description"]
  end

  def tags
    api_response.dig("tag_list", "tag").to_a.map { |t| t["name"] }.compact
  end

  def user_id
    api_response["user_id"]
  end

  def user_name
    if @work_type == "illust"
      api_response["nickname"]
    elsif @work_type == "manga"
      user_api_response(user_id)["nickname"]
    end
  end

  def api_response
    if @work_type == "illust"
      resp = get("https://sp.seiga.nicovideo.jp/ajax/seiga/im#{@work_id}")
      return {} if resp.blank? || resp.code.to_i == 404
      api_response = JSON.parse(resp)["target_image"]

    elsif @work_type == "manga"
      resp = Danbooru::Http.cache(1.minute).get("#{XML_API}/theme/info?id=#{@work_id}")
      return {} if resp.blank? || resp.code.to_i == 404
      api_response = Hash.from_xml(resp.to_s)["response"]["theme"]
    end

    api_response || {}
  rescue JSON::ParserError
    {}
  end

  def manga_api_response
    resp = get("https://ssl.seiga.nicovideo.jp/api/v1/app/manga/episodes/#{@work_id}/frames")
    return {} if resp.blank? || resp.code.to_i == 404
    JSON.parse(resp)["data"]["result"]
  rescue JSON::ParserError
    {}
  end

  def user_api_response(user_id)
    resp = Danbooru::Http.cache(1.minute).get("#{XML_API}/user/info?id=#{user_id}")
    return {} if resp.blank? || resp.code.to_i == 404
    Hash.from_xml(resp.to_s)["response"]["user"]
  end

  def get(url)
    cookie_header = Cache.get("nicoseiga-cookie-header") || regenerate_cookie_header

    resp = Danbooru::Http.headers({Cookie: cookie_header}).cache(1.minute).get(url)

    if resp.headers["Location"] =~ %r{seiga\.nicovideo\.jp/login/}i
      cookie_header = regenerate_cookie_header
      resp = Danbooru::Http.headers({Cookie: cookie_header}).cache(1.minute).get(url)
    end

    resp
  end

  def regenerate_cookie_header
    form = {
      mail_tel: Danbooru.config.nico_seiga_login,
      password: Danbooru.config.nico_seiga_password
    }
    resp = Danbooru::Http.post("https://account.nicovideo.jp/api/v1/login", form: form)
    cookies = resp.cookies.map { |c| c.name + "=" + c.value }
    cookies << "accept_fetish_warning=2"

    Cache.put("nicoseiga-cookie-header", cookies.join(";"), 1.week)
  end

  memoize :api_response, :manga_api_response, :user_api_response
end
