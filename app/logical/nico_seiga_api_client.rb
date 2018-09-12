class NicoSeigaApiClient
  extend Memoist
  BASE_URL = "http://seiga.nicovideo.jp/api"
  attr_reader :illust_id

  def initialize(illust_id:, user_id: nil)
    @illust_id = illust_id
    @user_id = user_id
  end

  def image_id
    illust_xml["response"]["image"]["id"].to_i
  end

  def user_id
    @user_id || illust_xml["response"]["image"]["user_id"].to_i
  end

  def title
    illust_xml["response"]["image"]["title"]
  end

  def desc
    illust_xml["response"]["image"]["description"] || illust_xml["response"]["image"]["summary"]
  end

  def moniker
    artist_xml["response"]["user"]["nickname"]
  end

  def illust_xml
    uri = "#{BASE_URL}/illust/info?id=#{illust_id}"
    body, code = HttpartyCache.get(uri)
    if code == 200
      Hash.from_xml(body)
    else
      raise "nico seiga api call failed (code=#{code}, body=#{body})"
    end
  end
  memoize :illust_xml

  def artist_xml
    uri = "#{BASE_URL}/user/info?id=#{user_id}"
    body, code = HttpartyCache.get(uri)
    if code == 200
      Hash.from_xml(body)
    else
      raise "nico seiga api call failed (code=#{code}, body=#{body})"
    end
  end
  memoize :artist_xml
end
