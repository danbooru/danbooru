class NicoSeigaApiClient
  BASE_URL = "http://seiga.nicovideo.jp/api"
  attr_reader :user_id, :moniker, :image_id, :title, :desc

  def initialize(illust_id)
    get_illust(illust_id)
    get_artist(user_id)
  end

  def get_illust(id)
    uri = URI.parse("#{BASE_URL}/illust/info?id=#{id}")
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.is_a?(URI::HTTPS)) do |http|
      resp = http.request_get(uri.request_uri)
      if resp.is_a?(Net::HTTPSuccess)
        parse_illust_xml_response(resp.body)
      end
    end
  end

  def get_artist(id)
    uri = URI.parse("#{BASE_URL}/user/info?id=#{id}")
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.is_a?(URI::HTTPS)) do |http|
      resp = http.request_get(uri.request_uri)
      if resp.is_a?(Net::HTTPSuccess)
        parse_artist_xml_response(resp.body)
      end
    end
  end

  def parse_artist_xml_response(text)
    doc = Hash.from_xml(text)
    @moniker = doc["response"]["user"]["nickname"]
  end

  def parse_illust_xml_response(text)
    doc = Hash.from_xml(text)
    image = doc["response"]["image"]
    @image_id = image["id"].to_i
    @user_id = image["user_id"].to_i
    @title = image["title"]
    @desc = image["description"]
  end
end
