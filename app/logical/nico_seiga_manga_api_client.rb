class NicoSeigaMangaApiClient
  extend Memoist
  BASE_URL = "https://seiga.nicovideo.jp/api"
  attr_reader :theme_id

  def initialize(theme_id)
    @theme_id = theme_id
  end

  def user_id
    theme_info_xml["response"]["theme"]["user_id"].to_i
  end

  def title
    theme_info_xml["response"]["theme"]["title"]
  end

  def desc
    theme_info_xml["response"]["theme"]["description"]
  end

  def moniker
    artist_xml["response"]["user"]["nickname"]
  end

  def image_ids
    images = theme_data_xml["response"]["image_list"]["image"]
    images = [images] unless images.is_a?(Array)
    images.map {|x| x["id"]}
  end

  def tags
    theme_info_xml["response"]["theme"]["tag_list"]["tag"].map {|x| x["name"]}
  end

  def theme_data_xml
    uri = "#{BASE_URL}/theme/data?theme_id=#{theme_id}"
    body = NicoSeigaApiClient.agent.get(uri).body
    Hash.from_xml(body)
  end
  memoize :theme_data_xml

  def theme_info_xml
    uri = "#{BASE_URL}/theme/info?id=#{theme_id}"
    body = NicoSeigaApiClient.agent.get(uri).body
    Hash.from_xml(body)
  end
  memoize :theme_info_xml

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
