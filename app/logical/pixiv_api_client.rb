class PixivApiClient
  extend Memoist

  API_VERSION = "1"
  CLIENT_ID = "bYGKuGVw91e0NMfPGp44euvGt59s"
  CLIENT_SECRET = "HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK"
  CLIENT_HASH_SALT = "28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c"

  # Tools to not include in the tags list. We don't tag digital media, so
  # including these results in bad translated tags suggestions.
  TOOLS_BLACKLIST = %w[
    Photoshop Illustrator Fireworks Flash Painter PaintShopPro pixiv\ Sketch
    CLIP\ STUDIO\ PAINT IllustStudio ComicStudio RETAS\ STUDIO SAI PhotoStudio
    Pixia NekoPaint PictBear openCanvas ArtRage Expression Inkscape GIMP
    CGillust COMICWORKS MS_Paint EDGE AzPainter AzPainter2 AzDrawing
    PicturePublisher SketchBookPro Processing 4thPaint GraphicsGale mdiapp
    Paintgraphic AfterEffects drawr CLIP\ PAINT\ Lab FireAlpaca Pixelmator
    AzDrawing2 MediBang\ Paint Krita ibisPaint Procreate Live2D
    Lightwave3D Shade Poser STRATA AnimationMaster XSI CARRARA CINEMA4D Maya
    3dsMax Blender ZBrush Metasequoia Sunny3D Bryce Vue Hexagon\ King SketchUp
    VistaPro Sculptris Comi\ Po! modo DAZ\ Studio 3D-Coat
  ]

  class Error < StandardError; end
  class BadIDError < Error; end

  class WorkResponse
    attr_reader :json, :pages, :name, :moniker, :user_id, :page_count, :tags
    attr_reader :artist_commentary_title, :artist_commentary_desc

    def initialize(json)
      @json = json
      @name = json["user"]["name"]
      @user_id = json["user"]["id"]
      @moniker = json["user"]["account"]
      @page_count = json["page_count"].to_i
      @artist_commentary_title = json["title"].to_s
      @artist_commentary_desc = json["caption"].to_s
      @tags = json["tags"].reject {|x| x =~ /^http:/}
      @tags += json["tools"] - TOOLS_BLACKLIST

      if json["metadata"]
        if json["metadata"]["zip_urls"]
          @pages = json["metadata"]["zip_urls"]
        elsif page_count > 1
          @pages = json["metadata"]["pages"].map {|x| x["image_urls"]["large"]}
        end
      end

      if @pages.nil? && json["image_urls"]
        @pages = [json["image_urls"]["large"]]
      end
    end
  end

  class NovelResponse
    extend Memoist

    attr_reader :json

    def initialize(json)
      @json = json
    end

    def name
      json["user"]["name"]
    end

    def user_id
      json["user"]["id"]
    end

    def moniker
      json["user"]["account"]
    end

    def page_count
      json["page_count"].to_i
    end

    def artist_commentary_title
      json["title"]
    end

    def artist_commentary_desc
      json["caption"]
    end

    def tags
      json["tags"]
    end

    def pages
      # ex:
      # https://i.pximg.net/c/150x150_80/novel-cover-master/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b_master1200.jpg (6096b)
      # =>
      # https://i.pximg.net/novel-cover-original/img/2017/07/27/23/14/17/8465454_80685d10e6df4d7d53ad347ddc18a36b.jpg (532129b)
      [find_original(json["image_urls"]["small"])]
    end
    memoize :pages

    public

    PXIMG = %r!\Ahttps?://i\.pximg\.net/c/\d+x\d+_\d+/novel-cover-master/img/(?<timestamp>\d+/\d+/\d+/\d+/\d+/\d+)/(?<filename>\d+_[a-f0-9]+)_master\d+\.(?<ext>jpg|jpeg|png|gif)!i

    def find_original(x)
      if x =~ PXIMG
        return "https://i.pximg.net/novel-cover-original/img/#{$~[:timestamp]}/#{$~[:filename]}.#{$~[:ext]}"
      end

      return x
    end
  end

  def work(illust_id)
    params = { image_sizes: "large", include_stats: "true" }
    url = "https://public-api.secure.pixiv.net/v#{API_VERSION}/works/#{illust_id.to_i}.json"
    response = api_client.cache(1.minute).get(url, params: params)
    json = response.parse

    if response.status == 200
      WorkResponse.new(json["response"][0])
    elsif json["status"] == "failure" && json.dig("errors", "system", "message") =~ /対象のイラストは見つかりませんでした。/
      raise BadIDError.new("Pixiv ##{illust_id} not found: work was deleted, made private, or ID is invalid.")
    else
      raise Error.new("Pixiv API call failed (status=#{response.code} body=#{response.body})")
    end
  rescue JSON::ParserError
    raise Error.new("Pixiv API call failed (status=#{response.code} body=#{response.body})")
  end

  def novel(novel_id)
    url = "https://public-api.secure.pixiv.net/v#{API_VERSION}/novels/#{novel_id.to_i}.json"
    resp = api_client.cache(1.minute).get(url)
    json = resp.parse

    if resp.status == 200
      NovelResponse.new(json["response"][0])
    elsif json["status"] == "failure" && json.dig("errors", "system", "message") =~ /対象のイラストは見つかりませんでした。/
      raise Error.new("Pixiv API call failed (status=#{resp.code} body=#{body})")
    end
  rescue JSON::ParserError
    raise Error.new("Pixiv API call failed (status=#{resp.code} body=#{body})")
  end

  def access_token
    # truncate timestamp to 1-hour resolution so that it doesn't break caching.
    client_time = Time.zone.now.utc.change(min: 0).rfc3339
    client_hash = Digest::MD5.hexdigest(client_time + CLIENT_HASH_SALT)

    headers = {
      "Referer": "http://www.pixiv.net",
      "X-Client-Time": client_time,
      "X-Client-Hash": client_hash
    }

    params = {
      username: Danbooru.config.pixiv_login,
      password: Danbooru.config.pixiv_password,
      grant_type: "password",
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET
    }

    resp = http.headers(headers).cache(1.hour).post("https://oauth.secure.pixiv.net/auth/token", form: params)
    return nil unless resp.status == 200

    resp.parse.dig("response", "access_token")
  end

  def api_client
    http.headers(
      "Referer": "http://www.pixiv.net",
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Bearer #{access_token}"
    )
  end

  def http
    Danbooru::Http.new
  end

  memoize :access_token, :api_client, :http
end
