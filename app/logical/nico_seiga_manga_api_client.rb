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

  def theme_info_xml
    uri = "#{BASE_URL}/theme/info?id=#{theme_id}"
    body = NicoSeigaApiClient.agent.get(uri).body
    Hash.from_xml(body)
  end

  def artist_xml
    get("#{BASE_URL}/user/info?id=#{user_id}")
  end

  def get(url)
    response = Danbooru::Http.cache(1.minute).get(url)
    raise "nico seiga api call failed (code=#{response.code}, body=#{response.body})" if response.code != 200

    Hash.from_xml(response.to_s)
  end

  memoize :theme_data_xml, :theme_info_xml, :artist_xml
end
