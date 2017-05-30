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
    doc = Nokogiri::Slop(text)
    @moniker = doc.response.user.nickname.content
  end

  def parse_illust_xml_response(text)
    doc = Nokogiri::Slop(text)
    @image_id = doc.response.image.id.content.to_i
    @user_id = doc.response.image.user_id.content.to_i
    @title = doc.response.image.title.content
    @desc = [doc.response.image.description.try(:content), doc.response.image.summary.try(:content)].compact.join("\n\n")
  end
end
