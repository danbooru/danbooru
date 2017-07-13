class PixivApiClient
  API_VERSION = "1"
  CLIENT_ID = "bYGKuGVw91e0NMfPGp44euvGt59s"
  CLIENT_SECRET = "HP3RmkgAmEGro0gn1x9ioawQE8WMfvLXDz3ZqxpK"

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

  class Error < Exception ; end

  class WorksResponse
    attr_reader :json, :pages, :name, :moniker, :user_id, :page_count, :tags
    attr_reader :artist_commentary_title, :artist_commentary_desc

    def initialize(json)
      # Sample response: 
      # {
      #     "status": "success",
      #     "response": [
      #         {
      #             "id": 49270482,
      #             "title": "ツイログ",
      #             "caption": null,
      #             "tags": [
      #                 "神崎蘭子",
      #                 "双葉杏",
      #                 "アイドルマスターシンデレラガールズ",
      #                 "Star!!",
      #                 "アイマス5000users入り"
      #             ],
      #             "tools": [
      #                 "CLIP STUDIO PAINT"
      #             ],
      #             "image_urls": {
      #                 "large": "http://i3.pixiv.net/img-original/img/2015/03/14/17/53/32/49270482_p0.jpg"
      #             },
      #             "width": 1200,
      #             "height": 951,
      #             "stats": {
      #                 "scored_count": 8247,
      #                 "score": 81697,
      #                 "views_count": 191630,
      #                 "favorited_count": {
      #                     "public": 7804,
      #                     "private": 745
      #                 },
      #                 "commented_count": 182
      #             },
      #             "publicity": 0,
      #             "age_limit": "all-age",
      #             "created_time": "2015-03-14 17:53:32",
      #             "reuploaded_time": "2015-03-14 17:53:32",
      #             "user": {
      #                 "id": 341433,
      #                 "account": "nardack",
      #                 "name": "Nardack",
      #                 "is_following": false,
      #                 "is_follower": false,
      #                 "is_friend": false,
      #                 "is_premium": null,
      #                 "profile_image_urls": {
      #                     "px_50x50": "http://i1.pixiv.net/img19/profile/nardack/846482_s.jpg"
      #                 },
      #                 "stats": null,
      #                 "profile": null
      #             },
      #             "is_manga": true,
      #             "is_liked": false,
      #             "favorite_id": 0,
      #             "page_count": 2,
      #             "book_style": "none",
      #             "type": "illustration",
      #             "metadata": {
      #                 "pages": [
      #                     {
      #                         "image_urls": {
      #                             "large": "http://i3.pixiv.net/img-original/img/2015/03/14/17/53/32/49270482_p0.jpg",
      #                             "medium": "http://i3.pixiv.net/c/1200x1200/img-master/img/2015/03/14/17/53/32/49270482_p0_master1200.jpg"
      #                         }
      #                     },
      #                     {
      #                         "image_urls": {
      #                             "large": "http://i3.pixiv.net/img-original/img/2015/03/14/17/53/32/49270482_p1.jpg",
      #                             "medium": "http://i3.pixiv.net/c/1200x1200/img-master/img/2015/03/14/17/53/32/49270482_p1_master1200.jpg"
      #                         }
      #                     }
      #                 ]
      #             },
      #             "content_type": null
      #         }
      #     ],
      #     "count": 1
      # }

      @json = json
      @name = json["user"]["name"]
      @user_id = json["user"]["id"]
      @moniker = json["user"]["account"]
      @page_count = json["page_count"].to_i
      @artist_commentary_title = json["title"].to_s
      @artist_commentary_desc = json["caption"].to_s
      @tags = json["tags"].reject {|x| x =~ /^http:/}
      @tags += json["tools"] - TOOLS_BLACKLIST

      if page_count > 1
        @pages = json["metadata"]["pages"].map {|x| x["image_urls"]["large"]}
      else
        @pages = [json["image_urls"]["large"]]
      end
    end
  end

  def works(illust_id)
    headers = {
      "Referer" => "http://www.pixiv.net",
      "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}",
      "Content-Type" => "application/x-www-form-urlencoded",
      "Authorization" => "Bearer #{access_token}"
    }
    params = {
      "image_sizes" => "large",
      "include_stats" => "true"
    }

    url = "https://public-api.secure.pixiv.net/v#{API_VERSION}/works/#{illust_id.to_i}.json"
    resp = HTTParty.get(url, Danbooru.config.httparty_options.merge(query: params, headers: headers))

    if resp.success?
      json = parse_api_json(resp.body)
      WorksResponse.new(json["response"][0])
    else
      raise Error.new("Pixiv API call failed (status=#{resp.code} body=#{resp.body})")
    end
  end

private
  def parse_api_json(body)
    json = JSON.parse(body)

    if json["status"] != "success"
      raise Error.new("Pixiv API call failed (status=#{json['status']} body=#{body})")
    end

    json
  end

  def access_token
    Cache.get("pixiv-papi-access-token", 3000) do
      access_token = nil
      headers = {
        "Referer" => "http://www.pixiv.net"
      }
      params = {
        "username" => Danbooru.config.pixiv_login,
        "password" => Danbooru.config.pixiv_password,
        "grant_type" => "password",
        "client_id" => CLIENT_ID,
        "client_secret" => CLIENT_SECRET
      }
      url = "https://oauth.secure.pixiv.net/auth/token"

      resp = HTTParty.post(url, Danbooru.config.httparty_options.merge(body: params, headers: headers))
      if resp.success?
        json = JSON.parse(resp.body)
        access_token = json["response"]["access_token"]
      else
        raise Error.new("Pixiv API access token call failed (status=#{resp.code} body=#{resp.body})")
      end

      access_token
    end
  end
end
