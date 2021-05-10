class NicoSeigaApiClient
  extend Memoist
  XML_API = "https://seiga.nicovideo.jp/api"

  attr_reader :http

  def initialize(work_id:, type:, http: Danbooru::Http.new)
    @work_id = work_id
    @work_type = type
    @http = http
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
      resp = http.cache(1.minute).get("#{XML_API}/theme/info?id=#{@work_id}")
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
    resp = http.cache(1.minute).get("#{XML_API}/user/info?id=#{user_id}")
    return {} if resp.blank? || resp.code.to_i == 404
    Hash.from_xml(resp.to_s)["response"]["user"]
  end

  def login
    form = {
      mail_tel: Danbooru.config.nico_seiga_login,
      password: Danbooru.config.nico_seiga_password
    }

    # XXX should fail gracefully instead of raising exception
    resp = http.cache(1.hour).post("https://account.nicovideo.jp/login/redirector?site=seiga", form: form)
    raise RuntimeError, "NicoSeiga login failed (status=#{resp.status} url=#{url})" if resp.status != 200

    http
  end

  def get(url)
    resp = login.cache(1.minute).get(url)
    #raise RuntimeError, "NicoSeiga get failed (status=#{resp.status} url=#{url})" if resp.status != 200

    resp
  end

  memoize :api_response, :manga_api_response, :user_api_response
end
